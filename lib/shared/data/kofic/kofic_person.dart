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
