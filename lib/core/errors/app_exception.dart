class AppException implements Exception {
  final String userMessage;
  final String technicalMessage;

  const AppException({
    required this.userMessage,
    required this.technicalMessage,
  });

  @override
  String toString() => technicalMessage;
}

class MissingApiKeyException extends AppException {
  final String service;

  const MissingApiKeyException(this.service)
    : super(
        userMessage: '$service 연결 설정이 없습니다. API 키를 적용해 앱을 다시 빌드해주세요.',
        technicalMessage: 'Missing API key for $service',
      );
}

class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException()
    : super(
        userMessage: '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
        technicalMessage: 'Network is unavailable',
      );
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
    : super(
        userMessage: '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.',
        technicalMessage: 'Request timed out',
      );
}

class ApiResponseException extends AppException {
  final int statusCode;

  ApiResponseException({required this.statusCode, required String operation})
    : super(
        userMessage: statusCode >= 500
            ? '서버가 일시적으로 응답하지 않습니다. 잠시 후 다시 시도해주세요.'
            : statusCode == 429
            ? '요청이 많아 잠시 기다려야 합니다. 잠시 후 다시 시도해주세요.'
            : '요청을 처리하지 못했습니다.',
        technicalMessage: '$operation failed with HTTP $statusCode',
      );
}

String userMessageForError(Object? error, {required String fallback}) {
  return error is AppException ? error.userMessage : fallback;
}
