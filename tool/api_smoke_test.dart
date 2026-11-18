import 'dart:io';

import 'package:filmcock_app/shared/domain/models/catalog_models.dart';
import 'package:filmcock_app/shared/data/catalog/remote_catalog_repository.dart';

const _catalog = RemoteCatalogRepository();

Future<void> main() async {
  var failed = false;

  Future<void> checkMovies(
    String label,
    Future<List<Movie>> Function() request,
  ) async {
    try {
      final movies = await request();
      stdout.writeln('$label: ${movies.length}건');
      for (final movie in movies.take(3)) {
        stdout.writeln('  - ${movie.title} (${movie.releaseDate})');
      }
      if (movies.isEmpty) failed = true;
    } catch (error) {
      failed = true;
      stderr.writeln('$label 실패: $error');
    }
  }

  await checkMovies('개봉 예정 영화', _catalog.getUpcomingMovies);
  await checkMovies('애니메이션 영화', () => _catalog.getMoviesByGenre(16));
  await checkMovies('고전 영화', _catalog.getClassicMovies);

  try {
    final people = await _catalog.getPopularPeopleFromKofic();
    final actors = people['actors'] ?? const <Person>[];
    stdout.writeln('한국 배우: ${actors.length}명');
    for (final actor in actors.take(3)) {
      stdout.writeln('  - ${actor.name}');
    }
    if (actors.isEmpty) failed = true;
  } catch (error) {
    failed = true;
    stderr.writeln('한국 배우 조회 실패: $error');
  }

  try {
    final people = await _catalog.getPopularPeople();
    stdout.writeln('해외 배우: ${people.length}명');
    for (final person in people.take(3)) {
      stdout.writeln('  - ${person.name}');
    }
    if (people.isEmpty) failed = true;
  } catch (error) {
    failed = true;
    stderr.writeln('해외 배우 조회 실패: $error');
  }

  if (failed) exitCode = 1;
}
