import 'package:real_calc/core/seed_works/error.dart';
import 'package:real_calc/core/utils/br_number_format.dart';

enum UnexpectedErrorMessages implements ErrorMessages {
  defaultError("Ocorreu um erro inesperado. Tente novamente");

  @override
  final String message;

  const UnexpectedErrorMessages(this.message);
}

enum ServerErrorMessages implements ErrorMessages {
  connectionError("Erro de conexão com o servidor"),
  invalidResponse("O servidor não devolveu dados válidos");

  @override
  final String message;

  const ServerErrorMessages(this.message);
}

enum SelicValidationMessage implements ErrorMessages {
  initialDateAfterFinalDate('A data inicial deve ser anterior à data final'),
  periodExceedsLimit('O período consultado não pode ser maior que 10 anos');

  @override
  final String message;

  const SelicValidationMessage(this.message);
}

enum FinancialCalculationValidationMessage implements ErrorMessages {
  allParametersNull('Informe os parâmetros do cálculo'),
  invalidParameterCount(
    'Informe exatamente três parâmetros para realizar o cálculo',
  ),
  resultOutOfRange(
    'Com esses valores, o resultado passa de R\$ 1 trilhão ou não pode ser '
    'calculado. Confira os campos.',
  ),
  resultTooSmall(
    'Com esses valores, o resultado fica abaixo de 0,01 e não pode ser '
    'mostrado. Confira os campos.',
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
  unableToDetermineCalculationType(
    'Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.',
  ),
  noPositiveRate(
    'As prestações somam menos que o valor financiado, então não existe uma '
    'taxa de juros para essa conta.',
  ),
  paymentAboveDebt(
    'A prestação já quita o valor financiado com os juros na primeira '
    'parcela. Confira os valores.',
  );

  @override
  final String message;

  const FinancingValidationMessage(this.message);
}

enum RegularDepositsValidationMessage implements ErrorMessages {
  positiveDepositValue('O valor do deposito deve ser maior que zero'),
  positiveFinalValue('O valor final deve ser maior que zero'),
  positiveRate('O valor da taxa deve ser maior que zero'),
  positiveMonths('A quantidade de meses deve ser maior que zero'),
  unableToDetermineCalculationType(
    'Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.',
  ),
  noPositiveRate(
    'O valor final não passa da soma dos depósitos, então não há rendimento '
    'nem taxa de juros para calcular.',
  ),
  finalBelowFirstMonth(
    'O valor final é menor que o primeiro depósito com o rendimento do mês. '
    'Confira os valores.',
  );

  @override
  final String message;

  const RegularDepositsValidationMessage(this.message);
}

enum FutureValueValidationMessage implements ErrorMessages {
  positiveCapital('O capital deve ser maior que zero'),
  positiveFinalValue('O valor final deve ser maior que zero'),
  positiveInterestRate('A taxa de juros deve ser maior que zero'),
  positiveMonths('A quantidade de meses deve ser maior que zero'),
  unableToDetermineCalculationType(
    'Não foi possível determinar o tipo de cálculo. Verifique os parâmetros informados.',
  ),
  finalNotAboveInitial(
    'O valor futuro precisa ser maior que o valor aplicado. Confira os valores.',
  );

  @override
  final String message;

  const FutureValueValidationMessage(this.message);
}

enum ValueCorrectionValidationMessage implements ErrorMessages {
  invalidPeriod(
    "A data inicial não pode ser maior do que a data final. Por favor, corrija o intervalo selecionado.",
  ),
  invalidIndex(
    "O período selecionado não possui dados disponíveis para o índice escolhido. Por favor, tente um intervalo diferente.",
  ),
  invalidPercentage(
    "O percentual informado deve ser maior que zero. Por favor, insira um valor positivo",
  ),
  invalidValue(
    "O valor inserido deve ser maior que zero. Certifique-se de preencher o campo corretamente",
  ),
  resultOutOfRange(
    'Com esse valor, o resultado passa de R\$ 1 trilhão. Confira o valor '
    'informado.',
  );

  @override
  final String message;

  const ValueCorrectionValidationMessage(this.message);
}

class SeriesUnavailableError implements ErrorMessages {
  const SeriesUnavailableError(this.lastAvailableMonth);

  final DateTime lastAvailableMonth;

  @override
  String get message =>
      'A série não possui dados para o período solicitado. O último mês disponível é ${_formatMonth(lastAvailableMonth)}.';

  static String _formatMonth(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class PaymentBelowInterestError implements ErrorMessages {
  const PaymentBelowInterestError(this.firstMonthInterest);

  final double firstMonthInterest;

  @override
  String get message =>
      'Com essa prestação, a dívida nunca é quitada: ela precisa ser maior '
      'que os juros do primeiro mês, de '
      '${formatCents(toCents(firstMonthInterest))}.';
}

class AmbiguousPeriodsError implements ErrorMessages {
  const AmbiguousPeriodsError(this.from);

  final int from;

  @override
  String get message =>
      'Com esses valores, qualquer prazo a partir de $from meses dá o mesmo '
      'resultado em centavos, então não dá para descobrir o prazo. Informe o '
      'prazo para descobrir outro campo.';
}
