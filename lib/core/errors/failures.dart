import 'package:equatable/equatable.dart';

import '../seed_works/error.dart';

sealed class Failure extends Equatable {
  final List<ErrorMessages> message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}



class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}