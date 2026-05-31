abstract class Result<L, R> {
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess);

  bool get isError => this is ValidationError;
  bool get isSuccess => this is ValidationSuccess;

  Result<L, R2> map<R2>(R2 Function(R success) onSuccess);
}

class ValidationError<L, R> extends Result<L, R> {
  final L value;
  ValidationError(this.value);

  @override
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess) {
    return onError(value);
  }

  @override
  Result<L, R2> map<R2>(R2 Function(R success) onSuccess) {
    return ValidationError<L, R2>(value);
  }
}

class ValidationSuccess<L, R> extends Result<L, R> {
  final R value;
  ValidationSuccess(this.value);

  @override
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess) {
    return onSuccess(value);
  }

  @override
  Result<L, R2> map<R2>(R2 Function(R success) onSuccess) {
    return ValidationSuccess<L, R2>(onSuccess(value));
  }
}
