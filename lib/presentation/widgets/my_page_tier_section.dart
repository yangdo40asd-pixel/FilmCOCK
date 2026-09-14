import 'package:flutter/material.dart';

class MyPageTierSection extends StatelessWidget {
  final int currentTier;
  final String progressText;

  const MyPageTierSection({
    super.key,
    required this.currentTier,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '영화를 많이 볼수록 등급이 오릅니다!',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badge('초심자', 'assets/images/tier/tier_beginner.png', 1),
              _connector(2),
              _badge('고수', 'assets/images/tier/tier_master.png', 2),
              _connector(3),
              _badge('초고수', 'assets/images/tier/tier_grandmaster.jpeg', 3),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              progressText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connector(int tier) => Expanded(
    child: Container(
      height: 3,
      color: currentTier >= tier ? const Color(0xFF8B5CF6) : Colors.white12,
    ),
  );

  Widget _badge(String title, String imagePath, int tier) {
    final unlocked = currentTier >= tier;
    final current = currentTier == tier;
    return Semantics(
      label: '$title 등급 ${unlocked ? '달성' : '미달성'}',
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: current
                  ? Border.all(color: const Color(0xFFA88BFA), width: 2.5)
                  : null,
            ),
            child: ClipOval(
              child: Opacity(
                opacity: unlocked ? 1 : 0.35,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.military_tech,
                    size: 36,
                    color: unlocked ? const Color(0xFF8B5CF6) : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: unlocked ? null : Colors.grey[600],
              fontSize: 12,
              fontWeight: current ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
