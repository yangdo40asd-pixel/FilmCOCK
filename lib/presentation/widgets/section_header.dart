import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title $emoji',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              // fontFamily: 'NotoSans' 는 AppTheme에서 전역으로 적용되므로 생략 가능
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text(
              '목록 보기 >',
              style: TextStyle(
                color: Color(0xFF6A5ACD), // 보라색
                // fontFamily: 'NotoSans' 는 AppTheme에서 전역으로 적용되므로 생략 가능
              ),
            ),
          ),
        ],
      ),
    );
  }
}
