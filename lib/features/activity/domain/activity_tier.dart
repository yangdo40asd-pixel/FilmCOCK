/// 관람 수 + 댓글 수의 기존 등급 정책. 좋아요 개수는 등급에 포함하지 않는다.
class ActivityTier {
  final int watchedCount;
  final int commentCount;

  const ActivityTier({required this.watchedCount, required this.commentCount});

  int get total => watchedCount + commentCount;
  int get level => total >= 15
      ? 3
      : total >= 5
      ? 2
      : 1;
  String get progressText => total >= 15
      ? '최고 등급인 초고수에 도달했습니다! 🎉'
      : '초고수까지 영화 ${15 - total}편 또는 댓글 ${15 - total}개 남았어요!';
}
