import 'package:filmcock_app/data/dummy/korean_people_data.g.dart';
import 'package:filmcock_app/data/models/movie_model.dart';

/// 생성된 대용량 인물 데이터에 대한 안정적인 공개 진입점입니다.
class KoreanPeopleData {
  const KoreanPeopleData._();

  static List<Person> get masterActors =>
      KoreanPeopleDataGenerated.masterActors;

  static List<Person> get masterDirectors =>
      KoreanPeopleDataGenerated.masterDirectors;
}
