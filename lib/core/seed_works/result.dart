abstract class Result<L, R> {
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess);

  // Alterado os nomes das checagens para termos genéricos
  bool get isError => this is FailureResult;
  bool get isSuccess => this is SuccessResult;

  Result<L, R2> map<R2>(R2 Function(R success) onSuccess);

  R? getOrNull() => fold((_) => null, (success) => success);
  L? getErrorOrNull() => fold((error) => error, (_) => null);
  R getOrElse(R Function() orElse) => fold((_) => orElse(), (success) => success);
}

class FailureResult<L, R> extends Result<L, R> {
  final L value;
  FailureResult(this.value);

  @override
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess) => onError(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R success) onSuccess) => FailureResult<L, R2>(value);
}

class SuccessResult<L, R> extends Result<L, R> {
  final R value;
  SuccessResult(this.value);

  @override
  T fold<T>(T Function(L error) onError, T Function(R success) onSuccess) => onSuccess(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R success) onSuccess) => SuccessResult<L, R2>(onSuccess(value));
}
