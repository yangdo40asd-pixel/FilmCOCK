import 'package:flutter/material.dart';
import 'package:filmcock_app/presentation/screens/movie_model.dart';
import 'package:filmcock_app/presentation/screens/movie_detail_screen.dart';
import 'package:filmcock_app/presentation/screens/actor_detail_screen.dart';

class ListViewScreen extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  const ListViewScreen({super.key, required this.title, required this.items});

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
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 한 줄에 3개씩 표시
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          // 아이템의 가로세로 비율 조정
          childAspectRatio: (items.first is Movie) ? (100 / 180) : (80 / 110),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is Movie) {
            return _buildMovieItem(context, item);
          } else if (item is Person) {
            return _buildPersonItem(context, item);
          }
          return const SizedBox.shrink(); // 해당 없는 타입은 빈 위젯
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
              child: Image.network(
                movie.fullPosterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey[800]),
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
          MaterialPageRoute(builder: (_) => ActorDetailScreen(actor: person)),
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
            person.name,
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
