import 'dart:io';
import 'package:filmcock_app/data/services/api_service.dart';

void main() async {
  final file = File('test_output.txt');
  var sink = file.openWrite();
  
  sink.writeln('--- Testing Animation Movies ---');
  try {
    final movies = await ApiService.getMoviesByGenre(16);
    sink.writeln('Animation count: ' + movies.length.toString());
    for (var i = 0; i < (movies.length > 3 ? 3 : movies.length); i++) {
      sink.writeln(' - ' + movies[i].title);
    }
  } catch (e) {
    sink.writeln('Animation error: ' + e.toString());
  }

  sink.writeln('--- Testing Classic Movies ---');
  try {
    final movies = await ApiService.getClassicMovies();
    sink.writeln('Classic count: ' + movies.length.toString());
    for (var i = 0; i < (movies.length > 3 ? 3 : movies.length); i++) {
      sink.writeln(' - ' + movies[i].title + ' (Release: ' + movies[i].releaseDate + ')');
    }
  } catch (e) {
    sink.writeln('Classic error: ' + e.toString());
  }

  await sink.close();
}