# FilmCOCK

영화 탐색, 개봉 예정작 확인, MBTI 기반 추천, 인물 검색과 규칙 기반 추천 챗봇을
제공하는 Flutter 앱입니다.

## 개발 환경 준비

1. Flutter SDK와 Android Studio를 설치합니다.
2. 프로젝트 폴더에서 `flutter pub get`을 실행합니다.
3. Firebase Android/iOS 앱 설정이 현재 패키지와 일치하는지 확인합니다.
4. `config/api_keys.example.json`을 `config/api_keys.json`으로 복사하고 본인의
   TMDB·KOFIC 키를 입력합니다.

실제 API 키 파일(`config/api_keys.json`)은 Git에서 제외되며 앱 에셋으로 포함되어 별도 옵션 없이
`flutter run`만으로 읽힙니다(`--dart-define-from-file`로 주입하는 방식도 계속 지원).

```shell
flutter run
flutter build apk
```

`config/api_keys.json`의 빈 값에는 재발급한 실제 키를 입력해야 합니다. 키가 없으면
외부 영화 API 요청은 즉시 실패하며 화면에서 설정 누락 원인과 재시도 상태를
표시합니다. 모바일 앱에 포함된 값은 완전한 비밀로 보호할 수 없으므로 비용이나
민감한 권한이 연결된 API는 서버 프록시를 통해 호출해야 합니다.

## 검사와 테스트

저장소에 TMDB·KOFIC 키나 인증 토큰이 다시 하드코딩되지 않았는지 사용자가 다음
명령으로 확인할 수 있습니다.

```powershell
powershell -ExecutionPolicy Bypass -File tool/check_secrets.ps1
```

```shell
flutter analyze
flutter test
```

재발급한 실제 API 키로 외부 연동만 빠르게 확인하려면 다음 검사를 실행합니다.

```shell
dart run -DTMDB_API_KEY=발급값 -DKOFIC_API_KEY=발급값 tool/api_smoke_test.dart
```

출시용 Android APK는 다음 명령으로 생성합니다.

```shell
flutter build apk --release
```

생성 위치는 `build/app/outputs/flutter-apk/app-release.apk`입니다. 실제 배포 전에는
Android 실기기 설치, 로그인 방식별 재인증·회원탈퇴, 검색, 홈 새로고침, 외부 링크,
라이트·다크 모드를 각각 확인해야 합니다. iOS 빌드와 서명 검증은 macOS에서 별도로
진행합니다.

## 주요 구조

- `lib/core`: 환경 설정, 테마, 공통 유틸리티
- `lib/data`: 모델, API·챗봇 서비스, 검색 캐시와 정적 데이터
- `lib/presentation`: 홈, 검색, 챗봇, 상세, 온보딩, 프로필 화면
- `test`: 날짜 경계, 모델 파싱, 챗봇 의도 분기 자동 테스트
- `MAINTENANCE_CHECKLIST.md`: 우선순위별 보수 계획과 완료 상태

## 현재 주의사항

- 챗봇 질문 칩은 앱 내부 규칙으로, 자유 입력은 Firebase AI Logic(Gemini Flash)으로
  해석합니다. LLM이 제안한 영화는 TMDB 검색으로 확인된 것만 표시하며, LLM이 꺼져 있거나
  실패하면 규칙 기반으로 자동 대체됩니다. 사용하려면 Firebase 콘솔에서 AI Logic(Gemini
  Developer API)과 App Check를 설정하세요. LLM은 기본으로 켜져 있으며 `--dart-define=ENABLE_LLM_CHAT=false`로
  끌 수 있습니다. App Check는 기본 꺼짐이며, 콘솔에 앱을 등록한 뒤 `--dart-define=ENABLE_APP_CHECK=true`로 켭니다.
- 홈 캐시는 메모리 기반이며 앱을 완전히 종료하면 초기화됩니다.
- 과거 Git 이력에 포함된 API 키는 코드 변경만으로 폐기되지 않습니다. 각 제공자
  콘솔에서 기존 키를 폐기하고 새 키의 사용 범위와 쿼터를 제한해야 합니다.
