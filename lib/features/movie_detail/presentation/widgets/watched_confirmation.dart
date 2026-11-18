import 'package:flutter/material.dart';

Future<void> showWatchedConfirmation(BuildContext context, String title) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '캘린더에 추가되었습니다.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Text(
          "'$title'이(가) 오늘 캘린더에 성공적으로 등록되었습니다.",
          style: TextStyle(
            color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFFA88BFA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
