import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class DMNarrationScreen extends StatefulWidget {
  final Map<String, int> roles;

  const DMNarrationScreen({super.key, required this.roles});

  @override
  State<DMNarrationScreen> createState() => _DMNarrationScreenState();
}

class _DMNarrationScreenState extends State<DMNarrationScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  // Game state
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentStepIndex = 0;
  String _currentText = "准备开始...";

  // Script management
  List<ScriptSegment> _scriptSegments = [];
  Timer? _pauseTimer;

  // Counts
  late int _percivalCount;
  late int _evilCount;
  late int _oberonCount;
  late int _mordredCount;

  @override
  void initState() {
    super.initState();
    _calculateCounts();
    _generateScript();
    _initTts();
  }

  void _calculateCounts() {
    _percivalCount = widget.roles['派西维尔'] ?? 0;
    _oberonCount = widget.roles['笨蛋'] ?? 0;
    _mordredCount = widget.roles['莫德雷德'] ?? 0;
    // Evils: Morgana, Assassin, Minion, Oberon
    _evilCount = (widget.roles['莫甘娜'] ?? 0) +
        (widget.roles['刺客'] ?? 0) +
        (widget.roles['爪牙'] ?? 0) +
        _oberonCount +
        _mordredCount;
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Continue to next step when speaking is done
    _flutterTts.setCompletionHandler(_onTtsComplete);
  }

  void _generateScript() {
    _scriptSegments = [];

    // Helper to add speech
    void speak(String text) {
      _scriptSegments.add(ScriptSegment(text: text, isPause: false));
    }

    // Helper to add pause
    void pause(int seconds) {
      _scriptSegments.add(ScriptSegment(duration: Duration(seconds: seconds), isPause: true));
    }

    // --- Script Generation Logic ---

    speak("请所有玩家坐好，准备开始游戏。");
    speak("现在进入夜晚阶段。");
    speak("所有玩家，请闭上眼睛，伸出拳头。");

    pause(5);

    // Conditional logic based on Oberon count
    if (_oberonCount > 0) {
      speak("坏人阵营，除了笨蛋，请睁开眼睛，竖起大拇指。");
    } else {
      speak("坏人阵营，请睁开眼睛，竖起大拇指。");
    }

    int visibleEvils = _evilCount - _oberonCount;
    speak("坏人阵营，互相确认身份，应该有$visibleEvils人。");

    pause(8);

    speak("坏人阵营，请收起大拇指，闭上眼睛。");

    pause(5);

    speak("梅林，请睁开眼睛。");

    pause(3);

    if (_mordredCount > 0) {
      int visibleToMerlin = _evilCount - _mordredCount;
      if (_oberonCount > 0) {
        speak("除了莫德雷德，所有坏人，包括笨蛋，请竖起大拇指，应该有$visibleToMerlin人。");
      } else {
        speak("除了莫德雷德，所有坏人，请竖起大拇指，应该有$visibleToMerlin人。");
      }
    } else {
      if (_oberonCount > 0) {
        speak("所有坏人，包括笨蛋，请竖起大拇指，应该有$_evilCount人。");
      } else {
        speak("所有坏人，请竖起大拇指，应该有$_evilCount人。");
      }
    }

    pause(8);

    speak("坏人，请放下大拇指。");
    speak("梅林，请闭上眼睛。");

    pause(5);
    if (_percivalCount > 0) {
      speak("派西维尔，请睁开眼睛。");
      speak("梅林和莫甘娜，请竖起大拇指。");

      pause(8);

      speak("请放下大拇指。");
      speak("派西维尔，请闭上眼睛。");

      pause(2);
    }

    speak("所有玩家，请睁开眼睛。");
    speak("天亮了，游戏正式开始。");
  }

  Future<void> _startNarration() async {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
      if (_currentStepIndex >= _scriptSegments.length) {
        _currentStepIndex = 0;
      }
    });
    _playNextSegment();
  }

  void _pauseNarration() async {
    setState(() {
      _isPaused = true;
      _isPlaying = false; // Visually stop
    });
    await _flutterTts.stop();
    _pauseTimer?.cancel();
  }

  void _resumeNarration() {
    setState(() {
       _isPlaying = true;
       _isPaused = false;
    });
    _playNextSegment();
  }

  void _resetNarration() async {
    await _flutterTts.stop();
    _pauseTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _currentStepIndex = 0;
      _currentText = "准备开始...";
    });
  }

  Future<void> _playNextSegment() async {
    if (!_isPlaying || _isPaused) return;

    if (_currentStepIndex >= _scriptSegments.length) {
      setState(() {
        _isPlaying = false;
        _currentText = "播报结束";
      });
      return;
    }

    ScriptSegment segment = _scriptSegments[_currentStepIndex];

    // Advance index *before* executing so if we pause, we resume at the *next* logical point?
    // Or resume current?
    // Simplification: Increment after completion for pauses, but TTS uses completion handler.
    // For Logic flow: Let's increment *after* the action is initiated, but for UI display we want to show current.

    setState(() {
      if (segment.isPause) {
        _currentText = "等待中... (${segment.duration!.inSeconds}秒)";
      } else {
        _currentText = segment.text!;
      }
    });

    if (segment.isPause) {
       _pauseTimer = Timer(segment.duration!, () {
         if (_isPlaying && !_isPaused) {
           setState(() {
             _currentStepIndex++;
           });
           _playNextSegment();
         }
       });
    } else {
      // It's speech
      // TTS completion handler will trigger next segment, so we just calculate next index here for readiness
      // But wait! The completion handler calls `_playNextSegment`.
      // So we must increment index *inside* the handler or *before* the handler is called for the *next* round?
      // Actually, if we increment here, the state is updated.

      // Correct flow for TTS:
      // 1. Speak.
      // 2. On Complete -> increment index -> _playNextSegment.

      // But `pause` logic above handles its own "completion".
      // So for TTS we rely on `completionHandler`.
      // We need to NOT increment index immediately for TTS.
      // But we DO need to increment it when it FINISHES.
      // The completion handler is global.

      // Let's refactor `_playNextSegment` slightly to be safer.
      // The index should be incremented when the segment is DONE.

      var result = await _flutterTts.speak(segment.text!);
      if (result == 1) {
          // Speak started. Wait for completion handler.
          // Note: On iOS/Android speak returns 1 if start successful.
      }
    }
  }

  void _onTtsComplete() {
    // This method is called by the global completion handler
    if (_isPlaying && !_isPaused) {
      // Check if current segment was speech (it should be)
      if (_currentStepIndex < _scriptSegments.length && !_scriptSegments[_currentStepIndex].isPause) {
         setState(() {
           _currentStepIndex++;
         });
         _playNextSegment();
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pauseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('DM 语音播报'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Q-style Image placeholder
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.record_voice_over, size: 80, color: Colors.pinkAccent),
            ),
            const SizedBox(height: 40),

            // Text Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _currentText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const Spacer(),

            // progress indicator
            if (_isPlaying || _isPaused)
            LinearProgressIndicator(
              value: _scriptSegments.isEmpty ? 0 : _currentStepIndex / _scriptSegments.length,
              backgroundColor: Colors.grey[200],
              color: Colors.pinkAccent,
            ),

            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset Button
                 _buildControlButton(
                  icon: Icons.replay,
                  color: Colors.orange,
                  onPressed: _resetNarration,
                ),

                const SizedBox(width: 30),

                // Play/Pause Button
                if (_isPlaying)
                  _buildControlButton(
                    icon: Icons.pause,
                    color: Colors.amber,
                    onPressed: _pauseNarration,
                    size: 70,
                  )
                else if (_isPaused)
                   _buildControlButton(
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: _resumeNarration,
                    size: 70,
                  )
                else
                   _buildControlButton(
                    icon: Icons.play_arrow,
                    color: Colors.green,
                    onPressed: _startNarration,
                    size: 70,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 50
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          backgroundColor: color,
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

class ScriptSegment {
  final String? text;
  final Duration? duration;
  final bool isPause;

  ScriptSegment({this.text, this.duration, required this.isPause});
}
