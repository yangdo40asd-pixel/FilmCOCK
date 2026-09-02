import 'dart:io';
import 'package:filmcock_app/data/services/api_service.dart';

void main() async {
  final file = File('test_output_step1.txt');
  var sink = file.openWrite();
  try {
    final people = await ApiService.getPopularPeople();
    sink.writeln('Foreign Actors:');
    for (var i = 0; i < (people.length > 3 ? 3 : people.length); i++) {
      sink.writeln(' - ' + people[i].name + ', url: ' + people[i].fullProfileUrl);
    }
  } catch (e) {
    sink.writeln('Error: ' + e.toString());
  }
  await sink.close();
}