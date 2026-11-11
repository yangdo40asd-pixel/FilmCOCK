# FilmCOCK! — MBTI 기반 영화 탐색·추천 앱

**TMDB·KOFIC의 영화 정보를 통합하고 MBTI·선호 장르 추천, 영화·인물 검색, 개인 활동 기록과 AI 영화 도슨트를 제공하는 Flutter 모바일 앱입니다.**

[📖 상세 포트폴리오 (Notion)](https://app.notion.com/p/d3f045186b3b83518a168171688e9730) · [🎬 홈 화면 시연](https://docs.google.com/videos/d/1-TxoH4ac3quipFSc8eaJDf5GkxuQGwITrasAzeJ5OyA/play?usp=sharing)

## 📸 Preview

**시연 영상:** [로그인·MBTI 설정](https://docs.google.com/videos/d/1PTdPfdKoq4Ay6RSY3QZTwgkyYZfWJZMLnSp0hA5u9Hg/play?usp=sharing) · [홈](https://docs.google.com/videos/d/1-TxoH4ac3quipFSc8eaJDf5GkxuQGwITrasAzeJ5OyA/play?usp=sharing) · [검색](https://docs.google.com/videos/d/1MHVOTmyC4nUv0va4EdDz-usL-KNCf6HKaLyu9ycUzpg/play?usp=sharing) · [취향](https://docs.google.com/videos/d/1vb_Mj26Hyyzyb5sFSZqvP95gfEpRuthToi0bKAziCB0/play?usp=sharing) · [마이페이지](https://docs.google.com/videos/d/1JnW7qPKifnYk2dPd6euWiq9xlIa7Z28gtUIdJbe3Fqg/play?usp=sharing) · [챗봇](https://docs.google.com/videos/d/1c4ALfodGQSwbfI99pL-efw_eNdBRbtPPeWXp_R1vniA/play?usp=sharing)

실제 앱 화면과 아키텍처 이미지는 [Notion 포트폴리오](https://app.notion.com/p/d3f045186b3b83518a168171688e9730)에서 볼 수 있습니다.

## 📌 Project Overview

| 항목 | 내용 |
| --- | --- |
| 개발 유형 | 2인 팀 프로젝트 |
| 플랫폼 | Flutter 기반 모바일 앱 |
| 주요 역할 | 팀장, 시작·홈·검색·취향·주요 UI 및 데이터 연동, 발표 자료 구성 |
| 팀 공동 결과물 | 로그인, 영화 탐색·추천, 활동 기록, AI 영화 도슨트 통합 |

영화 데이터가 여러 서비스에 흩어져 있고 사용자의 취향에 맞는 작품을 탐색하기 어렵다는 문제를 해결하기 위해, **취향 설정 → 영화 검색·상세 조회 → 추천·관람 기록**을 하나의 사용자 흐름으로 구성했습니다.

> **역할 구분:** AI 영화 도슨트 챗봇의 핵심 구현은 팀원이 담당했습니다. 아래 챗봇 항목은 팀 프로젝트 전체의 완성 기능을 설명합니다.

## ✨ Key Features

1. **로그인·취향 설정** — Firebase 이메일·Google 로그인, 비회원 시작, 16개 MBTI 유형 및 선호 장르 설정.
2. **영화 탐색** — 인기·개봉 예정·장르별 목록, 영화·출연진·예고편·OTT 정보 조회.
3. **영화·인물 검색** — 자동완성, 최근 검색어, 영화·배우·감독 검색 및 추가 로딩.
4. **개인화 추천·활동 기록** — MBTI·선호 장르 추천, 좋아요, 관람 기록 캘린더, 취향 변경.
5. **AI 영화 도슨트 (팀 공동 결과물)** — Gemini 기반 자유 입력, 규칙 기반 질문 처리, TMDB로 실제 영화 확인 후 추천 표시.

## 🛠 Tech Stack

| 분류 | 기술 | 역할 |
| --- | --- | --- |
| Mobile | Flutter, Dart | 화면·내비게이션·사용자 상호작용 |
| Data | TMDB API, KOFIC API | 영화·인물·박스오피스 정보 |
| Auth / AI | Firebase Authentication, Firebase AI Logic (Gemini) | 사용자 인증 및 영화 도슨트 |
| Local Storage | SharedPreferences | 사용자별 취향·활동 기록 |
| Architecture | Screens & Widgets, Service / Repository 계층 | UI·데이터 처리 책임 분리 |

## 🏗 System Architecture

```text
[Flutter Screens / Widgets]
            │
  [Service / Repository]
      ├─ TMDB / KOFIC API ── 영화·인물·추천 데이터
      ├─ Firebase Auth ───── 로그인
      ├─ Firebase AI Logic ─ 자연어 질문·추천
      └─ SharedPreferences ─ 취향·활동 기록
```

`lib/presentation`의 화면과 `lib/data`의 영화·인물 검색 서비스, 추천·챗봇 서비스, 정적 데이터를 분리했습니다. 사용자별 취향 정보는 로그인 UID 또는 게스트 세션 기준으로 구분하여 보관합니다.

## 🔧 Challenges & Solutions

### 1. 외부 API 영화 데이터 품질 문제

- **문제:** 영화 제목·설명에 언어가 섞이거나 포스터·줄거리 정보가 부족한 항목이 화면에 노출되었습니다.
- **원인:** TMDB·KOFIC 응답이 화면 표시 조건에 맞게 일관되게 정규화되지 않았습니다.
- **해결:** 공통 `LanguageFilter`를 홈·검색·인물 필모그래피·박스오피스 결과에 적용했습니다.
- **결과:** 화면별 영화 노출 기준을 통일했습니다.

### 2. 배우·감독 프로필 매칭 문제

- **문제:** 영화인 프로필을 외부 응답만으로 일관되게 구성하기 어려웠습니다.
- **원인:** 인물 이름·식별자·프로필 데이터의 불일치 및 누락.
- **해결:** 배우 2,776명, 감독 225명의 정적 인물 데이터에 TMDB ID와 이미지 경로를 연결하고, KOFIC 요청 실패 시에도 기본 목록을 표시하도록 구성했습니다.
- **결과:** 영화인 검색·홈 영역에서 프로필 데이터의 안정적인 표시 경로를 확보했습니다.

## 📊 Results

- Flutter 기반 영화 탐색·추천 모바일 애플리케이션 제작 및 주요 사용자 흐름 시연.
- 외부 영화 API 처리, 추천 서비스, 검색 화면, 취향·관람 기록을 하나의 앱으로 통합.
- 데이터 필터링, API 예외 처리 및 캐시 대체 경로 등 앱 안정성 개선.

## 🚀 Getting Started

### Requirements

- Flutter SDK, Android Studio
- 앱 패키지와 일치하는 Firebase Android/iOS 설정
- TMDB·KOFIC API 키
- AI 영화 도슨트를 사용할 경우 Firebase AI Logic (Gemini Developer API) 설정

### Installation & Run

1. Flutter SDK 및 Android Studio를 설치합니다.
2. 프로젝트에서 `flutter pub get`을 실행합니다.
3. Firebase 앱 설정이 현재 패키지와 일치하는지 확인합니다.
4. `config/api_keys.example.json`을 `config/api_keys.json`으로 복사하고 본인의 TMDB·KOFIC 키를 입력합니다.

```shell
flutter pub get
flutter run
```

키 파일 `config/api_keys.json`은 Git에서 제외되며 앱 에셋으로 포함되어 기본 `flutter run`으로 읽힙니다. `--dart-define-from-file`을 통한 주입도 지원합니다. 키가 누락되면 외부 API 호출이 실패하고 화면에 설정 누락 및 재시도 상태가 표시됩니다.

### Tests & Build

```shell
flutter analyze
flutter test
flutter build apk --release
```

릴리스 APK 경로는 `build/app/outputs/flutter-apk/app-release.apk`입니다.

API 키·인증 토큰이 실수로 하드코딩되지 않았는지 다음 스크립트로 검사할 수 있습니다.

```powershell
powershell -ExecutionPolicy Bypass -File tool/check_secrets.ps1
```

외부 API 연동 검사:

```shell
dart run -DTMDB_API_KEY=발급값 -DKOFIC_API_KEY=발급값 tool/api_smoke_test.dart
```

### Project Structure

```text
lib/core/          설정·테마·공통 유틸리티
lib/data/          API·챗봇 서비스, 모델, 캐시, 정적 데이터
lib/presentation/  홈·검색·챗봇·상세·온보딩·프로필 화면
test/              모델 파싱·날짜 경계·챗봇 의도 분기 테스트
```

추가 유지보수 항목은 `MAINTENANCE_CHECKLIST.md`에 기록되어 있습니다.

### Deployment & Security Notes

- 모바일 앱에 포함된 API 키는 완전한 비밀로 보호할 수 없습니다. 비용이나 민감한 권한이 연결된 키는 서버 프록시를 사용해야 합니다.
- 과거 Git 이력에 포함된 API 키는 소스에서 지우는 것만으로 무효화되지 않습니다. 해당 키를 제공자 콘솔에서 폐기·재발급하고 사용 범위와 쿼터를 제한해야 합니다.
- 챗봇의 질문 칩은 내부 규칙으로 처리하고 자유 입력은 Firebase AI Logic(Gemini Flash)으로 해석합니다. 추천된 영화는 TMDB 검색으로 확인하며, 실패 시 규칙 기반으로 대체됩니다.
- LLM은 기본 활성화이며 `--dart-define=ENABLE_LLM_CHAT=false`로 끌 수 있습니다. 현재 App Check 패키지는 사용하지 않으며, 실제 배포 전 도입 검토가 필요합니다.
- 홈 캐시는 메모리 기반이며 앱 종료 시 초기화됩니다.
- 실제 배포 전 Android 실기기에서 인증·회원탈퇴·검색·홈 새로고침·외부 링크·라이트/다크 모드를 확인해야 합니다. iOS 빌드·서명 검증은 macOS 환경에서 별도 수행합니다.

## 🔗 Links

- [상세 포트폴리오 — 역할·아키텍처·트러블슈팅·실제 화면](https://app.notion.com/p/d3f045186b3b83518a168171688e9730)
- [프로젝트 시연 영상 모음](https://docs.google.com/videos/d/1-TxoH4ac3quipFSc8eaJDf5GkxuQGwITrasAzeJ5OyA/play?usp=sharing)
