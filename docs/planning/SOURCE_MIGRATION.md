# 소스 경로 이관표

갱신일: 2026-11-17 · 상태: 코드 이동 완료 / 실행 검증 대기

이동 전 기준은 f2c3e98이다. 일부 모델은 역할별로 분할했으며 최종 호출처 이행 후 호환 파일은 제거했다.

| 이전 lib 경로 | 현재 lib 경로 |
| --- | --- |
| core/utils/language_filter.dart | shared/domain/policies/language_filter.dart |
| data/cache/home_cache_storage.dart | features/home/data/home_cache_storage.dart |
| data/cache/search_cache.dart | shared/data/search/search_cache.dart |
| data/chatbot/chatbot_database.dart | features/chat/data/curated_movie_catalog.dart |
| data/dummy/korean_people_data.dart | shared/data/reference/korean_people_data.dart |
| data/dummy/korean_people_data.g.dart | shared/data/reference/generated/korean_people_data.g.dart |
| data/llm/chat_plan.dart | features/chat/domain/chat_plan.dart |
| data/llm/docent_prompt.dart | features/chat/application/docent_prompt.dart |
| data/llm/firebase_llm_client.dart | features/chat/data/firebase_llm_client.dart |
| data/llm/llm_client.dart | features/chat/domain/llm_client.dart |
| data/models/chat_intent.dart | features/chat/domain/chat_intent.dart |
| data/models/genre_catalog.dart | features/preferences/domain/genre_catalog.dart |
| data/models/home_prefetch_data.dart | features/home/domain/home_prefetch_data.dart |
| data/models/mbti_info.dart | features/preferences/domain/mbti_info.dart |
| data/models/movie_model.dart | shared/domain/models/catalog_models.dart |
| data/models/search_suggestion.dart | shared/domain/models/search_suggestion.dart |
| data/repositories/activity_repository.dart | features/activity/data/activity_repository.dart |
| data/repositories/calendar_repository.dart | features/calendar/data/calendar_repository.dart |
| data/repositories/search_history_repository.dart | features/search/data/search_history_repository.dart |
| data/repositories/user_settings_repository.dart | features/preferences/data/user_settings_repository.dart |
| data/services/activity_change_service.dart | features/activity/application/activity_change_service.dart |
| data/services/api_client.dart | core/network/api_client.dart |
| data/services/chatbot_service.dart | features/chat/application/chatbot_service.dart |
| data/services/daily_recommendation_service.dart | features/recommendations/domain/daily_recommendation_service.dart |
| data/services/home_prefetch_service.dart | features/home/data/home_prefetch_service.dart |
| data/services/kofic_service.dart | shared/data/kofic/kofic_service.dart |
| data/services/local_user_data_service.dart | features/auth/data/local_user_data_service.dart |
| data/services/movie_history_service.dart | features/activity/data/movie_history_service.dart |
| data/services/notification_settings_service.dart | features/profile/application/notification_settings_service.dart |
| data/services/personalized_recommendation_service.dart | features/recommendations/application/personalized_recommendation_service.dart |
| data/services/preference_change_service.dart | features/preferences/application/preference_change_service.dart |
| data/services/search_service.dart | shared/data/search/search_service.dart |
| data/services/tmdb_movie_service.dart | shared/data/tmdb/tmdb_movie_service.dart |
| data/services/tmdb_person_service.dart | shared/data/tmdb/tmdb_person_service.dart |
| data/storage/app_storage_keys.dart | core/storage/app_storage_keys.dart |
| data/storage/safe_json_storage.dart | core/storage/safe_json_storage.dart |
| presentation/controllers/home_controller.dart | features/home/application/home_controller.dart |
| presentation/controllers/search_screen_controller.dart | features/search/application/search_screen_controller.dart |
| presentation/screens/calendar/calendar_add_movie_screen.dart | features/calendar/presentation/screens/calendar_add_movie_screen.dart |
| presentation/screens/calendar/calendar_screen.dart | features/calendar/presentation/screens/calendar_screen.dart |
| presentation/screens/chat/chat_screen.dart | features/chat/presentation/screens/chat_screen.dart |
| presentation/screens/detail/actor_detail_screen.dart | features/person_detail/presentation/screens/actor_detail_screen.dart |
| presentation/screens/detail/artist_detail_screen.dart | features/person_detail/presentation/screens/artist_detail_screen.dart |
| presentation/screens/detail/movie_detail_screen.dart | features/movie_detail/presentation/screens/movie_detail_screen.dart |
| presentation/screens/home/home_screen.dart | features/home/presentation/screens/home_screen.dart |
| presentation/screens/home/list_view_screen.dart | features/home/presentation/screens/list_view_screen.dart |
| presentation/screens/home/main_screen.dart | features/home/presentation/screens/main_screen.dart |
| presentation/screens/onboarding/genre_select_screen.dart | features/onboarding/presentation/screens/genre_select_screen.dart |
| presentation/screens/onboarding/login_screen.dart | features/auth/presentation/screens/login_screen.dart |
| presentation/screens/onboarding/mbti_detail_screen.dart | features/onboarding/presentation/screens/mbti_detail_screen.dart |
| presentation/screens/onboarding/mbti_panel_screen.dart | features/onboarding/presentation/screens/mbti_panel_screen.dart |
| presentation/screens/onboarding/mbti_screen.dart | features/onboarding/presentation/screens/mbti_screen.dart |
| presentation/screens/onboarding/mbti_select_screen.dart | features/onboarding/presentation/screens/mbti_select_screen.dart |
| presentation/screens/profile/my_comments_screen.dart | features/profile/presentation/screens/my_comments_screen.dart |
| presentation/screens/profile/my_page_screen.dart | features/profile/presentation/screens/my_page_screen.dart |
| presentation/screens/profile/preference_screen.dart | features/preferences/presentation/screens/preference_screen.dart |
| presentation/screens/profile/profile_edit_screen.dart | features/profile/presentation/screens/profile_edit_screen.dart |
| presentation/screens/profile/settings_screen.dart | features/profile/presentation/screens/settings_screen.dart |
| presentation/screens/search/search_results_screen.dart | features/search/presentation/screens/search_results_screen.dart |
| presentation/screens/search/search_screen.dart | features/search/presentation/screens/search_screen.dart |
| presentation/screens/splash/splash_screen.dart | app/presentation/splash_screen.dart |
| presentation/widgets/app_loading_indicator.dart | shared/presentation/widgets/app_loading_indicator.dart |
| presentation/widgets/app_network_image.dart | shared/presentation/widgets/app_network_image.dart |
| presentation/widgets/home_external_sections.dart | features/home/presentation/widgets/home_external_sections.dart |
| presentation/widgets/movie_info_section.dart | features/movie_detail/presentation/widgets/movie_info_section.dart |
| presentation/widgets/movie_poster.dart | features/movie_detail/presentation/widgets/movie_poster.dart |
| presentation/widgets/my_page_tier_section.dart | features/profile/presentation/widgets/my_page_tier_section.dart |
| presentation/widgets/notification_dialog.dart | shared/presentation/widgets/notification_dialog.dart |
| presentation/widgets/poster_image.dart | shared/presentation/widgets/poster_image.dart |
| presentation/widgets/section_header.dart | shared/presentation/widgets/section_header.dart |
| presentation/widgets/watch_options_sheet.dart | features/movie_detail/presentation/widgets/watch_options_sheet.dart |

## 검사 소스

| 이전 | 현재 |
| --- | --- |
| test/widget_test.dart | test/unit/models/movie_models_test.dart |
| test/release_date_utils_test.dart | test/unit/core/release_date_utils_test.dart |
| test/mbti_info_test.dart | test/unit/preferences/mbti_info_test.dart |
| test/local_user_data_service_test.dart | test/unit/auth/local_user_data_service_test.dart |
| test/chat_intent_test.dart | test/unit/chat/chat_intent_test.dart |
| test/chatbot_service_test.dart | test/unit/chat/chatbot_service_test.dart |
| test/chatbot_movies_asset_test.dart | test/unit/chat/chatbot_movies_asset_test.dart |
| test/chatbot_llm_test.dart | test/unit/chat/chatbot_llm_test.dart |

## 정리한 구형 코드

호출 참조가 없던 MbtiScreen, 샘플 ArtistAvatar, 호출처 이행이 끝난 ApiService 및 옛 모델 호환 파일을 제거했다. 기존 이력의 기준 커밋에서 확인·복구할 수 있다. 생성 인물 데이터 값·런타임 assets·실제 키 파일은 삭제하지 않았다.
