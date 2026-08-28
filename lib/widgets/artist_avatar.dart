// 1. 방금 만든 아티스트 상세 화면 import
import 'package:filmcock_app/screens/artist_detail_screen.dart';
import 'package:flutter/material.dart';

class ArtistAvatar extends StatelessWidget {
  final int artistId;
  final String name;

  const ArtistAvatar({super.key, required this.artistId, required this.name});

  @override
  Widget build(BuildContext context) {
    // 2. GestureDetector 위젯으로 감싸서 탭을 감지
    return GestureDetector(
      onTap: () {
        // 3. 탭하면 ArtistDetailScreen으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArtistDetailScreen(
              // 4. 아티스트 ID와 이름을 전달
              artistId: artistId,
              artistName: name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(
                'https://picsum.photos/id/${artistId + 100}/100/100',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
