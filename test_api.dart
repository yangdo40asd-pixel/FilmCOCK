import 'dart:io';
import 'package:filmcock_app/data/services/api_service.dart';

void main() async {
  final file = File('test_output.txt');
  var sink = file.openWrite();
  
  sink.writeln('--- Testing Upcoming Movies ---');
  try {
    final upcoming = await ApiService.getUpcomingMovies();
    sink.writeln('Upcoming count: ${upcoming.length}');
    for (var i = 0; i < (upcoming.length > 3 ? 3 : upcoming.length); i++) {
      sink.writeln(' - ${upcoming[i].title} (Release: ${upcoming[i].releaseDate})');
    }
  } catch (e) {
    sink.writeln('Upcoming error: $e');
  }

  sink.writeln('\n--- Testing Korean Actors ---');
  try {
    final kofic = await ApiService.getPopularPeopleFromKofic();
    final actors = kofic['actors'] ?? [];
    sink.writeln('Korean Actors count: ${actors.length}');
    for (var i = 0; i < (actors.length > 5 ? 5 : actors.length); i++) {
      sink.writeln(' - ${actors[i].name} / ${actors[i].originalName}');
    }
  } catch (e) {
    sink.writeln('Korean actors error: $e');
  }

  sink.writeln('\n--- Testing Foreign Actors ---');
  try {
    final foreign = await ApiService.getPopularPeople();
    sink.writeln('Foreign Actors count: ${foreign.length}');
    for (var i = 0; i < (foreign.length > 5 ? 5 : foreign.length); i++) {
      sink.writeln(' - ${foreign[i].name} / ${foreign[i].originalName}');
    }
  } catch (e) {
    sink.writeln('Foreign actors error: $e');
  }
  await sink.close();
}
