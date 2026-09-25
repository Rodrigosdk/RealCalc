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

enum SelicValidationMessage implements ErrorMessages {
  invalidDate('Informe datas válidas no formato dd/MM/yyyy'),
  initialDateAfterFinalDate(
    'A data inicial deve ser anterior à data final',
  ),
  periodExceedsLimit('O período consultado não pode ser maior que 10 anos');

  @override
  final String message;

  const SelicValidationMessage(this.message);
}


enum FinancialCalculationValidationMessage implements ErrorMessages {
  allParametersNull('Informe os parâmetros do cálculo'),
  invalidParameterCount(
    'Informe exatamente três parâmetros para realizar o cálculo',
  );

  @override
  final String message;

  const FinancialCalculationValidationMessage(this.message);
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

enum RegularDepositsValidationMessage implements ErrorMessages {
  positiveDepositValue('O valor do deposito deve ser maior que zero'),
  positiveFinalValue('O valor final deve ser maior que zero'),
  positiveRate('O valor da taxa deve ser maior que zero'),
  positiveMonths('A quantidade de meses deve ser maior que zero'),
  unableToDetermineCalculationType('Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.');

  @override
  final String message;
  
  const RegularDepositsValidationMessage(this.message);
}

enum FutureValueValidationMessage implements ErrorMessages {
  positiveCapital('O capital deve ser maior que zero'),
  positiveFinalValue('O valor final deve ser maior que zero'),
  positiveInterestRate('A taxa de juros deve ser maior que zero'),
  positiveMonths('A quantidade de meses deve ser maior que zero'),
  unableToDetermineCalculationType('Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.');

  @override
  final String message;

  const FutureValueValidationMessage(this.message);
}

enum ValueCorrectionValidationMessage implements ErrorMessages {
  invalidPeriod("A data inicial não pode ser maior do que a data final. Por favor, corrija o intervalo selecionado."), 
  invalidIndex("O período selecionado não possui dados disponíveis para o índice escolhido. Por favor, tente um intervalo diferente."), 
  invalidPercentage("O percentual informado deve ser maior que zero. Por favor, insira um valor positivo"), 
  invalidValue("O valor inserido deve ser maior que zero. Certifique-se de preencher o campo corretamente");
  
  @override
  final String message;

  const ValueCorrectionValidationMessage(this.message);
}