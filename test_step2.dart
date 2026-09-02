import 'dart:io';
import 'package:filmcock_app/data/services/api_service.dart';

void main() async {
  final file = File('test_output_step2.txt');
  var sink = file.openWrite();
  try {
    final movies = await ApiService.getUpcomingMovies();
    sink.writeln('Upcoming Movies Count: ' + movies.length.toString());
    for (var i = 0; i < (movies.length > 5 ? 5 : movies.length); i++) {
      sink.writeln(' - ' + movies[i].title + ' (Release: ' + movies[i].releaseDate + ')');
    }
  } catch (e) {
    sink.writeln('Error: ' + e.toString());
  }
  await sink.close();
}