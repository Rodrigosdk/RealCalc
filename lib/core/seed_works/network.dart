import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/seed_works/error.dart';

/// Acesso HTTP usado pelos repositórios. Hoje o app só faz consultas (GET).
abstract class Network {
  Future<Result<ErrorMessages, T>> get<T>(String url);
}
