class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<Genre> genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    this.genres = const [],
  });

  // JSON 데이터를 Movie 객체로 변환하는 factory 생성자
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      // vote_average가 int로 올 수도 있고 double로 올 수도 있어서 num으로 받고 변환
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      genres: json['genres'] != null
          ? (json['genres'] as List).map((g) => Genre.fromJson(g)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genres': genres.map((genre) => genre.toJson()).toList(),
    };
  }

  // 이미지 URL을 완성하는 getter
  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';
  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w500$backdropPath'
      : '';
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Person {
  static final RegExp _unsupportedDisplayScript = RegExp(
    r'[\u3040-\u30FF\u3400-\u4DBF\u4E00-\u9FFF\u0400-\u04FF\u0600-\u06FF\u0900-\u097F\u0E00-\u0E7F]',
    unicode: true,
  );
  static final RegExp _koreanDisplayName = RegExp(r'^[가-힣\s·ㆍ]+$');

  final int id;
  final String name;
  final String originalName;
  final String? profilePath;
  final String knownForDepartment;
  final int filmographyCount;

  Person({
    required this.id,
    required this.name,
    this.originalName = '',
    this.profilePath,
    required this.knownForDepartment,
    this.filmographyCount = 0,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int? ?? 0,
      name: json['name'] ?? '',
      originalName: json['original_name'] ?? '',
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'] ?? '',
      filmographyCount: json['filmography_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'original_name': originalName,
      'profile_path': profilePath,
      'known_for_department': knownForDepartment,
      'filmography_count': filmographyCount,
    };
  }

  String get fullProfileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w200$profilePath' : '';

  // TMDB의 ko-KR 응답을 우선 사용하되, 번역이 없는 비라틴 원문은 화면에서 제외한다.
  String get displayName {
    if (name.trim().isEmpty || _unsupportedDisplayScript.hasMatch(name)) {
      return '';
    }
    return name.trim();
  }

  bool get hasKoreanDisplayName =>
      displayName.isNotEmpty && _koreanDisplayName.hasMatch(displayName);

  Person copyWith({int? filmographyCount}) {
    return Person(
      id: id,
      name: name,
      originalName: originalName,
      profilePath: profilePath,
      knownForDepartment: knownForDepartment,
      filmographyCount: filmographyCount ?? this.filmographyCount,
    );
  }
}

// KOFIC API 응답을 위한 모델
class KoficPerson {
  final String personCd; // 영화인 코드
  final String personNm; // 영화인명
  final String repRoleNm; // 대표분야 (배우, 감독 등)
  final String filmoNames; // 필모그래피

  KoficPerson({
    required this.personCd,
    required this.personNm,
    required this.repRoleNm,
    required this.filmoNames,
  });

  factory KoficPerson.fromJson(Map<String, dynamic> json) {
    return KoficPerson(
      personCd: json['peopleCd'] ?? '',
      personNm: json['peopleNm'] ?? '',
      repRoleNm: json['repRoleNm'] ?? '',
      filmoNames: json['filmoNames'] ?? '',
    );
  }

  // KOFIC에는 프로필 이미지 URL이 없으므로, 임시 이미지를 반환하는 getter
  String get placeholderImageUrl =>
      'https://via.placeholder.com/200x200.png?text=${Uri.encodeComponent(personNm)}';
}

class ReviewChannel {
  final String name;
  final String? logoAsset;
  final String youtubeUrl;

  ReviewChannel({required this.name, this.logoAsset, this.youtubeUrl = ''});
}

class Video {
  final String key;
  final String site;
  final String type;

  Video({required this.key, required this.site, required this.type});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      key: json['key'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

class WatchProvider {
  final int providerId;
  final String providerName;
  final String logoPath;
  final String link;
  final String offerType;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.link,
    required this.offerType,
  });

  factory WatchProvider.fromJson(
    Map<String, dynamic> json, {
    required String offerType,
    required String link,
  }) {
    return WatchProvider(
      providerId: json['provider_id'] as int? ?? 0,
      providerName: json['provider_name'] as String? ?? '',
      logoPath: json['logo_path'] as String? ?? '',
      link: link,
      offerType: offerType,
    );
  }

  String get fullLogoUrl =>
      logoPath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w200$logoPath';
}
