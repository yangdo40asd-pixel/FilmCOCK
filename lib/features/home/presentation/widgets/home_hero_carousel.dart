import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:filmcock_app/shared/domain/models/movie.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_network_image.dart';
import 'package:filmcock_app/features/movie_detail/presentation/screens/movie_detail_screen.dart';

class HomeHeroCarousel extends StatelessWidget {
  final List<Movie> movies;
  const HomeHeroCarousel({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox();
    return CarouselSlider.builder(
      itemCount: min(movies.length, 5), // 상위 5개만
      itemBuilder: (context, index, realIndex) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: movie.fullBackdropUrl),
              // 그라데이션 오버레이
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      '인기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: 250,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
      ),
    );
  }
}
