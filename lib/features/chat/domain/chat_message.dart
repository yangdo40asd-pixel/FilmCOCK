import 'package:filmcock_app/shared/domain/models/movie.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? followUpOptions;
  final List<Movie>? recommendedMovies;
  final List<String>? movieReasons;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.followUpOptions,
    this.recommendedMovies,
    this.movieReasons,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
