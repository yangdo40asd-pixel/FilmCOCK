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
