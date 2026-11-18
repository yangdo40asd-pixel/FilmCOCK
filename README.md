# FilmCOCK! — MBTI 기반 영화 탐색·추천 앱

TMDB·KOFIC 영화 정보를 통합하고, MBTI·선호 장르 추천부터 검색·상세 조회·개인 활동 기록까지 연결하는 Flutter 앱입니다. 영화 챗봇은 규칙 기반 질문과 Firebase AI Logic을 통한 자유 입력을 함께 지원합니다.

[상세 포트폴리오 · Notion](https://app.notion.com/p/d3f045186b3b83518a168171688e9730) · [홈 시연 영상](https://docs.google.com/videos/d/1-TxoH4ac3quipFSc8eaJDf5GkxuQGwITrasAzeJ5OyA/play?usp=sharing) · [기술 문서 목차](docs/README.md) · [리팩토링 진행표](docs/planning/PORTFOLIO_REFACTORING_PLAN.md)

## 프로젝트와 역할

영화 정보가 여러 서비스에 흩어져 있는 탐색 과정을 **취향 설정 → 검색·상세 조회 → 추천·관람 기록** 흐름으로 구성했습니다.

| 항목 | 내용 |
| --- | --- |
| 개발 형태 | 2인 팀 프로젝트 |
| 플랫폼 | Flutter 기반 모바일 앱 |
| 본인 역할 | 팀장, 시작·홈·검색·취향·주요 UI 및 데이터 연동, 발표 자료 구성 |
| 팀원 담당 | AI 영화 도슨트 챗봇의 핵심 구현 |
| 공동 결과물 | 인증·영화 탐색·추천·활동 기록·챗봇을 통합한 앱 |

챗봇 기능 설명은 팀 공동 결과물을 소개합니다. 최근 유지보수에서는 기능별 코드 구조와 문서를 정리하고 조회 계약, 저장 실패 처리, 요청 수명 관리와 검사 소스를 분리했습니다.

## 시연 자료

| 흐름 | 영상 |
| --- | --- |
| 로그인·MBTI 설정 | [시연 보기](https://docs.google.com/videos/d/1PTdPfdKoq4Ay6RSY3QZTwgkyYZfWJZMLnSp0hA5u9Hg/play?usp=sharing) |
| 홈 | [시연 보기](https://docs.google.com/videos/d/1-TxoH4ac3quipFSc8eaJDf5GkxuQGwITrasAzeJ5OyA/play?usp=sharing) |
| 검색 | [시연 보기](https://docs.google.com/videos/d/1MHVOTmyC4nUv0va4EdDz-usL-KNCf6HKaLyu9ycUzpg/play?usp=sharing) |
| 취향 | [시연 보기](https://docs.google.com/videos/d/1vb_Mj26Hyyzyb5sFSZqvP95gfEpRuthToi0bKAziCB0/play?usp=sharing) |
| 마이페이지 | [시연 보기](https://docs.google.com/videos/d/1JnW7qPKifnYk2dPd6euWiq9xlIa7Z28gtUIdJbe3Fqg/play?usp=sharing) |
| 챗봇 | [시연 보기](https://docs.google.com/videos/d/1c4ALfodGQSwbfI99pL-efw_eNdBRbtPPeWXp_R1vniA/play?usp=sharing) |

기존 시연 자료입니다. 이번 리팩토링 변경분의 실행 결과는 [검증 기록](docs/quality/VALIDATION_LOG.md)에서 별도로 관리합니다.

## 주요 기능

- **인증·취향 설정:** Firebase 이메일·Google 로그인, 비회원 시작, 16개 MBTI와 선호 장르 선택.
- **영화 탐색:** 인기·개봉 예정·장르별 영화, 출연진·예고편·OTT 제공 정보와 외부 시청 경로.
- **영화·인물 검색:** 자동완성, 최근 검색어, 배우·감독 검색, 결과 추가 로딩과 중복 제거.
- **개인화 추천:** 홈·취향·챗봇의 공통 추천 조건, 날짜별 추천과 저장한 영화 제외.
- **활동 기록:** 좋아요·봤어요·댓글·인물 좋아요, 마이페이지 개수·등급 및 관람 캘린더.
- **영화 챗봇:** 규칙 기반 질문 칩, LLM 자유 입력, 후보 영화 확인과 실패 시 규칙 응답 대체.

## 기술 구성

| 영역 | 기술·책임 |
| --- | --- |
| 앱 | Flutter, Dart — 화면·내비게이션·비동기 상태 |
| 영화 데이터 | TMDB, KOFIC/KOBIS — 영화·인물·박스오피스 조회 |
| 인증 | Firebase Authentication, Google Sign-In |
| AI | Firebase AI Logic — Gemini 요청, 구조화된 응답 검증 |
| 저장 | SharedPreferences — 취향·활동·프로필·검색 기록·홈 캐시 |
| UI·미디어 | Flutter SVG, Carousel Slider, YouTube Player, URL Launcher |
| 구조 | 기능별 모듈, 조회·취향 계약, 컨트롤러·정책·저장 구현 분리 |

취향은 계정·비회원 소유자별로 구분합니다. 활동·프로필·달력은 현재 기기 로컬 저장이며 서버 DB 동기화는 구현하지 않았습니다.

## 구조

```text
lib/
├── main.dart               앱 진입
├── app/                    초기화·시작 경로·프로덕션 의존성 조립
├── core/                   네트워크·저장·시계·테마·오류
├── shared/                 공용 모델·조회 계약·API 구현·공용 위젯
└── features/
    ├── auth/, onboarding/  인증·온보딩
    ├── home/, search/      홈 데이터·검색 상태
    ├── preferences/        취향 저장·변경
    ├── recommendations/    추천 조건·일일 추천 정책
    ├── chat/               대화·규칙·LLM 해석·후보 확인
    ├── movie_detail/       영화 상세·예고편·댓글 입력
    ├── person_detail/      영화인 상세
    └── activity/, calendar/, profile/

assets/                     실행 이미지·큐레이션 데이터
config/                     설정 예제, 실제 키 파일은 Git 제외
test/unit/, test/helpers/   역할별 검사 소스·가짜 조회·고정 시계
tool/                       데이터 관리·진단 도구
docs/                       요구사항·설계·개발·품질·포트폴리오·과거 기록
```

화면은 컨트롤러와 정책을 사용하고, 추천·검색·챗봇은 [CatalogRepository](lib/shared/domain/repositories/catalog_repository.dart)로 외부 조회를 구분합니다. 앱 조립부는 실제 API·LLM 구현을 연결하고, 검사에서는 가짜 구현을 주입합니다. 기존 화면 간 직접 이동과 일부 정적 구현은 남아 있습니다.

## 기술적으로 다룬 문제

| 문제 | 적용한 처리와 코드 |
| --- | --- |
| 늦게 도착한 검색 결과가 최신 목록을 덮는 위험 | [검색 결과 컨트롤러](lib/features/search/application/search_results_controller.dart)의 요청 번호·페이지 상태 관리 |
| 저장된 활동이 마이페이지에 늦게 보이는 문제 | [활동 저장소](lib/features/activity/data/activity_repository.dart)의 성공 후 변경 신호와 화면 재조회 |
| 목록·플래그·관람 캘린더의 부분 저장 실패 | 저장 작업 직렬화·실패 반환 확인·기존 값 복원 시도 |
| LLM이 제안한 영화의 확인 | [후보 검증](lib/features/chat/application/movie_candidate_verifier.dart)으로 조회 결과와 제목 비교·중복 제외 |
| 대화 초기화 후 이전 응답이 섞이는 문제 | [대화 컨트롤러](lib/features/chat/application/chat_session_controller.dart)에서 요청과 서비스 수명 분리 |
| 홈 데이터 지연·일부 API 실패 | 시작 화면 사전 준비, 섹션별 오류 처리, 메모리 및 마지막 정상 디스크 캐시 |

측정하지 않은 성능 향상률·추천 정확도는 성과로 기재하지 않습니다. 사례별 배경과 한계는 [기술 사례](docs/portfolio/TECHNICAL_CASE_STUDIES.md)에서 설명합니다.

## 실행하기

Flutter SDK와 Android 개발 환경을 준비합니다. 현재 Dart 제약은 `^3.9.0`이며, Firebase 플랫폼 설정과 인증·AI Logic 설정이 앱 패키지에 맞아야 합니다.

1. `config/api_keys.example.json`을 같은 폴더의 `api_keys.json`으로 복사합니다.
2. 발급받은 TMDB·KOFIC 키를 입력합니다.
3. 프로젝트 루트에서 실행합니다.

```powershell
flutter pub get
flutter run
```

실제 키 파일은 Git에서 제외되고 앱 시작 때 읽힙니다. 설정 항목과 재설치 시 준비 방법은 [API 키 메모](docs/development/API_KEYS_SETUP.md), LLM 끄기와 빌드 명령은 [개발 환경 안내](docs/development/SETUP.md)를 참고하세요.

## 검증 상태

현재 단위 검사 소스는 **13개 파일**이며 가짜 조회와 고정 시계로 외부 연동을 분리했습니다. 이번 리팩토링에서는 앱 실행·빌드·정적 분석·자동 테스트를 수행하지 않았습니다. 검사 파일 수를 통과한 테스트 수로 표현하지 않습니다.

사용자가 실행할 검사와 두 실테스트 묶음은 [검증 전략](docs/quality/TEST_STRATEGY.md), 실행 결과는 [검증 기록](docs/quality/VALIDATION_LOG.md)에 남깁니다.

## 문서 찾아보기

- [요구사항](docs/requirements/PRODUCT_REQUIREMENTS.md) · [구현 추적](docs/requirements/TRACEABILITY.md)
- [시스템 구조](docs/architecture/SYSTEM_OVERVIEW.md) · [데이터 모델](docs/architecture/DATA_MODEL.md) · [챗봇·추천](docs/architecture/CHAT_RECOMMENDATIONS.md)
- [리팩토링 계획](docs/planning/PORTFOLIO_REFACTORING_PLAN.md) · [소스 이관표](docs/planning/SOURCE_MIGRATION.md)
- [프로젝트 개요](docs/portfolio/PROJECT_OVERVIEW.md) · [시연 안내](docs/portfolio/DEMO_GUIDE.md) · [회고](docs/portfolio/RETROSPECTIVE.md)
- [개발 규약](CONTRIBUTING.md) · [전체 문서 목차](docs/README.md)

## 범위와 남은 확인

SharedPreferences의 다중 쓰기는 DB 트랜잭션이 아니며, 실패 복원도 저장 장치가 계속 실패하면 보장할 수 없습니다. MBTI 추천은 장르 규칙이며 학습 모델이나 심리학적 적합성 보장이 아닙니다.

실제 키는 Git에서 제외돼도 앱 에셋에 포함되면 추출될 수 있습니다. 기존 노출 키의 폐기, 외부 이미지·데이터 권리, 스토어 배포용 서명과 플랫폼별 실행 상태는 [보안](docs/quality/SECURITY.md) 및 [알려진 한계](docs/quality/KNOWN_LIMITATIONS.md)에 구분해 기록했습니다.
