import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/modules/metrics/use_cases/selic/selic_validation.dart';

void main() {
  late SelicValidation validation;

  setUp(() {
    validation = SelicValidation();
  });

  test('aceita período menor ou igual a dez anos', () {
    expect(
      validation.validatePeriod(
        dataInicial: DateTime(2016, 1, 1),
        dataFinal: DateTime(2026, 1, 1),
      ),
      isNull,
    );
  });

  test('rejeita data inicial igual ou posterior à data final', () {
    expect(
      validation.validatePeriod(
        dataInicial: DateTime(2026, 1, 2),
        dataFinal: DateTime(2026, 1, 1),
      ),
      SelicValidationMessage.initialDateAfterFinalDate,
    );
  });

  test('rejeita período maior que dez anos', () {
    expect(
      validation.validatePeriod(
        dataInicial: DateTime(2016, 1, 1),
        dataFinal: DateTime(2026, 1, 2),
      ),
      SelicValidationMessage.periodExceedsLimit,
    );
  });

  test('aceita datas com diferentes horários comparando o instante completo', () {
    expect(
      validation.validatePeriod(
        dataInicial: DateTime(2026, 1, 1, 23),
        dataFinal: DateTime(2026, 1, 2),
      ),
      isNull,
    );
  });
}
