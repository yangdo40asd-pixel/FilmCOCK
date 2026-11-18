import 'dart:io';
import 'package:flutter/material.dart';

class ProfileSummaryCard extends StatelessWidget {
  final String nickname;
  final String bio;
  final String? imagePath;
  final VoidCallback onEdit;

  const ProfileSummaryCard({
    super.key,
    required this.nickname,
    required this.bio,
    required this.imagePath,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: ClipOval(
              child:
                  (imagePath != null &&
                      imagePath!.isNotEmpty &&
                      File(imagePath!).existsSync())
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : Image.asset(
                      'assets/images/popcorn_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Name & Bio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bio,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Edit Profile Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: onEdit,
            child: Text(
              '프로필 수정',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
