class ReleaseDateUtils {
  const ReleaseDateUtils._();

  static int daysUntil(DateTime releaseDate, {DateTime? from}) {
    final current = from ?? DateTime.now();
    final release = DateTime(
      releaseDate.year,
      releaseDate.month,
      releaseDate.day,
    );
    final today = DateTime(current.year, current.month, current.day);
    return release.difference(today).inDays;
  }
}
