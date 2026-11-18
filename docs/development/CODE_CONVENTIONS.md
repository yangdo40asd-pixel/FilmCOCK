# 코드와 문서 규약

갱신일: 2026-11-17 · 상태: 현재

- app은 프로덕션 구현 조립·초기화·시작 경로를 소유한다.
- core는 범용 네트워크·저장·시계·테마·오류를 소유한다.
- shared/domain은 공용 영화·인물 모델과 조회 계약이다. shared/data는 외부 서비스 구현이다.
- features는 기능별 presentation/application/domain/data로 필요한 만큼 나눈다.
- domain에 Flutter 위젯·Firebase·SharedPreferences를 import하지 않는다.
- 앱 조회는 CatalogRepository 계약, 취향 조회는 PreferenceRepository 계약을 사용한다.
- 외부 SDK나 저장소가 필요한 구현은 주입 지점을 두고 실제 구현은 앱 조립부에서 연결한다. 일부 로컬 구현의 기본값은 호환을 위해 유지한다.
- 공개 application/domain 계약을 경유하고 다른 기능의 화면·data 내부 참조는 추가로 확대하지 않는다. 기존 화면 이동의 직접 참조는 후속 라우팅 개선 대상으로 기록한다.
- 한 파일의 길이보다 상태 소유자·오류 처리·수명이 분명한지를 먼저 본다.
- 생성 인물 파일은 입력 원본을 확보하기 전 수작업 재생성하지 않는다.
- 데이터 키를 경로명에 따라 바꾸지 않는다. 실패 시 복원은 최선 시도이며 DB 트랜잭션으로 표현하지 않는다.
- 문서는 planning/requirements/architecture/development/quality/portfolio/references/archive로 구분한다.
- 커밋·푸시·검사 결과는 실제 수행 상태로 기록한다. 현재 작업 규칙은 TEST_STRATEGY를 따른다.
