import 'package:real_calc/core/seed_works/error.dart';

enum CacheErrorMessages implements ErrorMessages {
  cacheError("Erro ao acessar o cache");

  @override
  final String message;

  const CacheErrorMessages(this.message);
}

enum UnexpectedErrorMessages implements ErrorMessages {
  defaultError("Ocorreu um erro inesperado. Tente novamente");

  @override
  final String message;

  const UnexpectedErrorMessages(this.message);
}

enum ServerErrorMessages implements ErrorMessages {
  connectionError("Erro de conexão com o servidor");

  @override
  final String message;

  const ServerErrorMessages(this.message);
}

enum FinancingValidationMessage implements ErrorMessages {
  positiveInitialValue('O valor inicial deve ser maior que zero'),
  positiveFinalValue('O valor final deve ser maior que zero'),
  positiveRate('O valor da taxa deve ser maior que zero'),
  positiveMonths('A quantidade de meses deve ser maior que zero'),
  unableToDetermineCalculationType('Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.');

  @override
  final String message;
  
  const FinancingValidationMessage(this.message);
}