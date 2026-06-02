abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}