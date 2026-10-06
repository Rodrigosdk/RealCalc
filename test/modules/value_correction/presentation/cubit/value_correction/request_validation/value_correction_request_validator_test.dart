import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/entites/period.dart';
import 'package:real_calc/modules/value_correction/domain/entites/value_correction.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/validation/value_correction_validation.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/value_correction/request_validation/value_correction_request_validator.dart';

void main() {
  late ValueCorrectionRequestValidator validator;

  setUp(() {
    validator = ValueCorrectionRequestValidator(ValueCorrectionValidation());
  });

  ValueCorrection params(DateTime start, DateTime end, {double value = 100}) {
    return ValueCorrection(
      index: CorrectionIndex.ipca.sgsCode,
      period: Period(initial: start, end: end),
      percentage: 0,
      originalValue: value,
      factor: 1,
      adjustedValue: value,
      variation: 0,
    );
  }

  group('ValueCorrectionRequestValidator', () {
    test('aceita período válido', () {
      expect(
        validator.validate(
          index: CorrectionIndex.ipca,
          params: params(DateTime(2024, 1), DateTime(2024, 12)),
        ),
        isNull,
      );
    });

    test('prioriza mensagem de disponibilidade mínima do índice', () {
      expect(
        validator.validate(
          index: CorrectionIndex.ipcaE,
          params: params(DateTime(1991, 12), DateTime(1992, 1)),
        ),
        CorrectionIndex.ipcaE.availabilityMessage,
      );
    });

    test('devolve a mensagem da validação de parâmetros', () {
      expect(
        validator.validate(
          index: CorrectionIndex.ipca,
          params: params(DateTime(2024, 2), DateTime(2024, 1)),
        ),
        'A data inicial não pode ser maior do que a data final. Por favor, corrija o intervalo selecionado.',
      );
    });

    test('rejeita períodos acima do limite de dez anos', () {
      expect(
        validator.validate(
          index: CorrectionIndex.ipca,
          params: params(DateTime(2010, 1), DateTime(2020, 2)),
        ),
        'O período entre as datas não pode ser superior a 10 anos exatos.',
      );
    });
  });
}
