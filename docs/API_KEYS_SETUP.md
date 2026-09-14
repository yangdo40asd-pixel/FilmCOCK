# FilmCOCK API 키 설정 메모

GitHub에서 프로젝트를 새로 받거나 다른 컴퓨터에서 실행할 때 아래 순서대로 설정한다.

## 1. 로컬 키 파일 만들기

프로젝트 폴더의 `config/api_keys.example.json`을 복사하여 같은 위치에
`config/api_keys.json`을 만든다.

최종 경로:

```text
Filmcock/config/api_keys.json
```

## 2. 발급받은 키 입력하기

새로 만든 `config/api_keys.json`에서 다음 세 항목의 예제 문구를 실제 발급값으로
교체한다.

```json
{
  "TMDB_API_KEY": "여기에 TMDB API 키 입력",
  "TMDB_READ_ACCESS_TOKEN": "여기에 TMDB 읽기 액세스 토큰 입력",
  "KOFIC_API_KEY": "여기에 KOFIC API 키 입력"
}
```

- TMDB는 API 키 또는 읽기 액세스 토큰 중 하나만 있어도 영화 정보를 요청할 수 있다.
- 현재 앱은 읽기 액세스 토큰이 있으면 이를 우선 사용한다.
- KOFIC 영화진흥위원회 키는 국내 박스오피스와 한국 영화인 정보에 사용한다.

## 3. 앱 실행하기

키 파일을 한 번 만든 뒤에는 매번 다시 만들거나 명령에 키를 입력할 필요가 없다.

```powershell
flutter pub get
flutter run
```

패키지 구성이 바뀌지 않았다면 이후에는 보통 `flutter run`만 실행하면 된다.
`flutter clean`은 빌드 캐시 문제를 해결할 때만 사용한다.

## 4. 꼭 기억할 주의사항

- `config/api_keys.json`은 로컬 전용 파일이며 GitHub에 올리지 않는다.
- `.gitignore`에 등록되어 있으므로 일반적인 `git add`에서는 제외된다.
- GitHub에는 값이 비어 있는 `config/api_keys.example.json`만 보관한다.
- 키가 노출되었다면 코드에서 지우는 것만으로 끝내지 말고 TMDB·KOFIC 콘솔에서
  기존 키를 폐기한 후 새로 발급한다.
- 저장소를 새로 복제하면 `config/api_keys.json`은 따라오지 않으므로 이 문서의
  1번부터 다시 진행한다.

## 5. 키가 적용되지 않을 때 확인할 것

1. 파일명이 정확히 `api_keys.json`인지 확인한다.
2. 파일 위치가 프로젝트 루트의 `config` 폴더인지 확인한다.
3. JSON의 쉼표와 큰따옴표가 빠지지 않았는지 확인한다.
4. 예제 문구가 실제 발급값으로 교체되었는지 확인한다.
5. 수정한 키 파일을 저장한 뒤 앱을 완전히 다시 실행한다.

실제 키 값은 이 문서, README, 소스 코드, 채팅 캡처에 기록하지 않는다.
