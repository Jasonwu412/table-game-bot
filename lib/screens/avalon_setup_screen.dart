import 'package:flutter/material.dart';
import 'package:table_game_bot/screens/dm_narration_screen.dart';

class AvalonSetupScreen extends StatefulWidget {
  const AvalonSetupScreen({super.key});

  @override
  State<AvalonSetupScreen> createState() => _AvalonSetupScreenState();
}

class _AvalonSetupScreenState extends State<AvalonSetupScreen> {
  // Key: Role Name, Value: Count
  final Map<String, int> _roles = {
    '梅林': 1,
    '派西维尔': 1,
    '忠臣': 0, // Loyal Servant
    '莫甘娜': 1,
    '刺客': 1,
    '爪牙': 0, // Minion
    '笨蛋': 0, // Oberon/Idiot
    '莫德雷德': 0, // Optional Evil Role
  };

  void _increment(String role) {
    setState(() {
      _roles[role] = (_roles[role] ?? 0) + 1;
    });
  }

  void _decrement(String role) {
    int minCount = (role == '梅林' || role == '刺客') ? 1 : 0;
    setState(() {
      if ((_roles[role] ?? 0) > minCount) {
        _roles[role] = (_roles[role] ?? 0) - 1;
      }
    });
  }

  int get _totalPlayers => _roles.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('阿瓦隆角色配置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '当前总人数',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    '$_totalPlayers',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Good Side
            _buildSectionHeader('正义阵营 (蓝方)', Colors.blue),
            _buildRoleCounter('梅林', Colors.blue),
            _buildRoleCounter('派西维尔', Colors.blue),
            _buildRoleCounter('忠臣', Colors.blue),

            const SizedBox(height: 20),

            // Evil Side
            _buildSectionHeader('邪恶阵营 (红方)', Colors.red),
            _buildRoleCounter('莫甘娜', Colors.red),
            _buildRoleCounter('刺客', Colors.red),
            _buildRoleCounter('爪牙', Colors.red),
            _buildRoleCounter('笨蛋', Colors.red),
            _buildRoleCounter('莫德雷德', Colors.red),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _totalPlayers >= 5
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DMNarrationScreen(roles: _roles),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('开始游戏'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _totalPlayers >= 5 ? Colors.pinkAccent : Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_totalPlayers < 5)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  '最少需要5人才能开始游戏',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 20,
            color: color,
            margin: const EdgeInsets.only(right: 10),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCounter(String role, Color color) {
    int minCount = (role == '梅林' || role == '刺客') ? 1 : 0;
    bool canDecrement = (_roles[role] ?? 0) > minCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            role,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              _buildCircleButton(
                Icons.remove,
                canDecrement ? () => _decrement(role) : null,
                canDecrement ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3)
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    '${_roles[role]}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _buildCircleButton(Icons.add, () => _increment(role), color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback? onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
