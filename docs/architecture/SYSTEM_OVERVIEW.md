# 시스템 구조 개요

갱신일: 2026-11-17 · 상태: 현재 구현과 목표 경계

## 현재 실행 흐름

1. main에서 Flutter 바인딩, API 설정, 테마를 준비한다.
2. MyApp이 Firebase와 마지막 홈 캐시 복원을 기다린다.
3. SplashScreen이 세션·온보딩 상태를 읽는 동안 홈 API 준비를 시작한다.
4. 로그인·MBTI·장르·메인 목적지를 결정한다. 메인 이동 전에는 홈 준비를 기다린다.
5. 홈의 개인화 조회는 기존 목록을 유지한 뒤 준비된 결과로 교체한다.

MyApp은 lib/app/app.dart, Firebase·캐시 초기화는 AppBootstrap, 세션·홈 준비 조합은 StartupFlow, 목적지 판정은 StartupRoute가 담당한다. SplashScreen은 판정 결과를 화면에 연결한다. 코드 참조를 새 공용 모델과 features 경로로 모두 옮긴 뒤 기존 movie_model.dart·ApiService 호환 진입점을 제거했다. AppDependencies가 실제 CatalogRepository·LLM 구현을 연결하며 검색·추천·챗봇과 저장·시계에 주입 지점을 제공한다.

API 요청 하나의 제한은 전체 시작 처리 시간의 상한이 아니다. 순차·다중 요청과 SDK 초기화의 전체 시간은 별도로 관찰해야 한다.

## 외부 서비스

| 구성 | 책임 |
| --- | --- |
| TMDB 영화·인물 API | 검색·상세·포스터 경로·영상·시청 제공자 |
| KOFIC/KOBIS | 국내 박스오피스·영화인 보조 조회 |
| Firebase Authentication | 이메일·Google 인증 세션 |
| Firebase AI Logic | 자유 입력 해석용 LLM 요청 |
| SharedPreferences | 취향·활동·프로필·검색·캐시 로컬 보관 |

현재 서버 DB 동기화 구현은 없다. 질문 칩은 규칙으로 처리하고 자유 입력은 사용 가능할 때 LLM을 먼저 호출한다. 구조화된 후보·의도를 앱에서 해석하며 실패하면 규칙 응답으로 대체한다.

## 목표 의존성

화면 → 컨트롤러/application → domain 계약 ← data 구현 순서로 책임을 나눈다. app 조립부가 실제 구현을 연결한다. 공용 영화·인물 모델과 조회는 shared, 범용 네트워크·저장은 core, 제품 정책은 해당 feature가 소유한다.

현재 완료 범위와 확인 대기 항목은 [진행 계획](../planning/PORTFOLIO_REFACTORING_PLAN.md)에 구분한다. 기존 화면 간 직접 이동과 일부 로컬 구현의 기본 의존성은 남아 있다. 새로운 변경에서 이 결합을 확대하지 않고 후속 라우팅·저장소 개선과 구분한다.
