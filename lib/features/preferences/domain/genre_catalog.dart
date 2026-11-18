class GenreCatalog {
  static const Map<String, int> tmdbIds = {
    'action': 28,
    'adventure': 12,
    'animation': 16,
    'comedy': 35,
    'crime': 80,
    'documentary': 99,
    'drama': 18,
    'family': 10751,
    'fantasy': 14,
    'history': 36,
    'horror': 27,
    'music': 10402,
    'mystery': 9648,
    'romance': 10749,
    'sf': 878,
    'thriller': 53,
    'war': 10752,
  };

  static const Map<String, String> labels = {
    'action': '액션',
    'adventure': '모험',
    'animation': '애니메이션',
    'comedy': '코미디',
    'crime': '범죄',
    'documentary': '다큐멘터리',
    'drama': '드라마',
    'family': '가족',
    'fantasy': '판타지',
    'history': '역사',
    'horror': '공포',
    'music': '음악',
    'mystery': '미스터리',
    'romance': '로맨스',
    'sf': 'SF',
    'thriller': '스릴러',
    'war': '전쟁',
  };

  static int? tmdbIdFor(String genreKey) => tmdbIds[genreKey];

  static String? labelFor(String genreKey) => labels[genreKey];
}
