import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  // 1. 알림을 받을 영화 제목 (임시)
  final String movieTitle;

  const NotificationDialog({
    super.key,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    // 2. AlertDialog 위젯을 사용해 팝업창을 만듭니다.
    return AlertDialog(
      backgroundColor: Colors.grey[850], // 팝업 배경색
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      // 3. 제목 (PDF 12페이지 참고)
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.white),
          SizedBox(width: 8),
          Text('상영 종료 임박 알림'),
        ],
      ),
      // 4. 본문 (PDF 12페이지 참고)
      content: Text(
        "영화 '$movieTitle'이(가) 3일 후 영화관에서 내려갑니다. 놓치지 마세요!",
        style: TextStyle(
          color: Colors.grey[300],
          height: 1.5,
        ),
      ),
      // 5. 하단 버튼들
      actions: [
        // '닫기' 버튼
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 팝업 닫기
          },
          child: const Text(
            '닫기',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // '예매하기' 버튼
        ElevatedButton(
          onPressed: () {
            // TODO: 예매 페이지로 이동
            Navigator.of(context).pop(); // 팝업 닫기
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('예매하기'),
        ),
      ],
    );
  }
}