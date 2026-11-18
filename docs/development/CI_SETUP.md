# CI 구성안과 실행 경계

갱신일: 2026-11-17 · 상태: 실행 비활성 구성안

현재 사용자의 실행 제한에 맞춰 GitHub Actions 자동 실행 파일을 활성화하지 않았다. 다음 항목은 사용자 또는 향후 승인된 CI 실행자가 수행할 검사 규약이다.

## 입력과 환경

- pubspec의 SDK 제약과 호환되는 Flutter SDK, 잠금 파일 기준 패키지
- 실제 API 키 없이 동작하는 로컬 fixture와 FakeCatalogRepository
- LLM은 DisabledLlmClient 또는 가짜 LlmClient 사용
- SDK 버전·대상 커밋을 기록하고 자동 최신 버전 교체는 별도 변경으로 처리

## 실행 순서

1. 패키지 준비: flutter pub get
2. 정적 분석: flutter analyze
3. 네트워크 격리 단위 검사: flutter test test/unit
4. 문서 링크·로컬 import·키 제외 상태 확인
5. 사용자 환경의 Android 빌드·실기기 확인은 별도 기록

일반 단위 검사에 실제 TMDB·KOFIC·LLM 호출을 허용하지 않는다. tool/api_smoke_test.dart와 데이터 갱신 도구는 자격정보와 외부 호출이 필요한 별도 사용자 작업이다.

## 활성화 조건

자동 실행을 도입하는 시점에 workflow_dispatch, PR, push 중 실행 범위와 SDK 버전·필요 권한을 정한다. 실행 결과를 저장하는 위치와 실패 시 병합 정책을 합의한다. 현재 작성된 템플릿은 이슈·PR 기록용이며 검사를 자동으로 실행하지 않는다.
