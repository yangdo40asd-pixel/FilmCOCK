import 'package:flutter/material.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/actor_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/artist_detail_screen.dart';
import 'package:filmcock_app/presentation/widgets/app_network_image.dart';

class ListViewScreen extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final List<Person> people;

  const ListViewScreen.movies({
    super.key,
    required this.title,
    required this.movies,
  }) : people = const <Person>[];

  const ListViewScreen.people({
    super.key,
    required this.title,
    required this.people,
  }) : movies = const <Movie>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF303030),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: movies.isNotEmpty ? movies.length : people.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 한 줄에 3개씩 표시
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          // 아이템의 가로세로 비율 조정
          childAspectRatio: movies.isNotEmpty ? (100 / 180) : (80 / 110),
        ),
        itemBuilder: (context, index) {
          if (movies.isNotEmpty) {
            return _buildMovieItem(context, movies[index]);
          }
          return _buildPersonItem(context, people[index]);
        },
      ),
    );
  }

  // 영화 아이템을 그리는 위젯
  Widget _buildMovieItem(BuildContext context, Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: AppNetworkImage(
                imageUrl: movie.fullPosterUrl,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            movie.title,
            style: const TextStyle(color: Colors.white, fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 인물(배우/감독) 아이템을 그리는 위젯
  Widget _buildPersonItem(BuildContext context, Person person) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => title == '유명 감독'
                ? ArtistDetailScreen(
                    artistId: person.id,
                    artistName: person.displayName,
                    profileUrl: person.fullProfileUrl,
                  )
                : ActorDetailScreen(actor: person),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: CircleAvatar(
                radius: 40.0,
                backgroundImage: person.fullProfileUrl.isNotEmpty
                    ? NetworkImage(person.fullProfileUrl)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            person.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 12.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
