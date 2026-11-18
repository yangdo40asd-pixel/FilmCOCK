# 개발 환경과 실행

갱신일: 2026-11-17 · 상태: 현재 설정 기준 / 새 환경 실행 미검증

## 준비

- pubspec의 Dart 제약은 ^3.9.0이다. 실제 사용한 Flutter SDK 버전은 사용자 환경에서 확인·기록한다.
- Android 개발에는 Flutter SDK, Android 도구 및 현재 Gradle 설정과 맞는 JDK가 필요하다. Android 소스는 Java 17 대상으로 설정돼 있다.
- iOS 빌드는 macOS 개발 환경이 필요하며 이번 작업에서 검증하지 않았다.
- Firebase 설정은 현재 패키지·프로젝트에 대응한다. 다른 프로젝트로 교체할 때 인증·AI Logic·플랫폼 설정을 함께 맞춘다.
- API 키는 [별도 설정 메모](API_KEYS_SETUP.md)를 따른다.

## 일반 개발

프로젝트 루트에서 사용자가 실행한다.

```powershell
flutter pub get
flutter run
```

키 파일은 최초 설정 후 계속 사용하며 캐시 문제가 없는 한 매번 flutter clean을 실행할 필요는 없다.

## LLM 설정

질문 칩은 규칙 기반이다. 자유 입력은 Firebase AI Logic 설정이 준비되면 기본 활성 LLM을 사용한다.

```powershell
flutter run --dart-define=ENABLE_LLM_CHAT=false
```

LLM_MODEL로 모델 이름을 바꿀 수 있다. 현재 기본값은 코드의 LlmConfig를 기준으로 하며 서비스 제공 가능 여부를 문서가 보증하지 않는다.

## 사용자 빌드

```powershell
flutter build apk --release
```

출력 위치는 build/app/outputs/flutter-apk/app-release.apk다. 현재 Android release는 debug 서명 설정을 사용하므로 실제 스토어 배포 서명 준비와 구분한다. iOS·웹·데스크톱 폴더가 있다는 이유로 지원 검증을 완료한 것으로 보지 않는다.

검사 실행 권한과 결과 기록은 [검증 전략](../quality/TEST_STRATEGY.md)을 따른다.

## 보관용 하위 저장소

루트 FilmCOCK!는 실행 코드가 아닌 별도 과거 저장소다. 이력 자료까지 필요할 때만 사용자가 git submodule update --init을 실행한다. 일반 앱 실행에는 해당 하위 저장소가 필요하지 않다.
