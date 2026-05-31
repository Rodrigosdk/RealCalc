class ValidationFailure {
  final List<String> errors;

  ValidationFailure(this.errors);

  @override
  String toString() => errors.join('; ');
}
