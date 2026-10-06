import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/date_granularity.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_state.dart';

void main() {
  late ValueCorrectionFormCubit cubit;

  setUp(() {
    cubit = ValueCorrectionFormCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  test('CDI mostra percentual e outros índices não', () {
    cubit.setIndex(CorrectionIndex.cdi);
    expect(cubit.state.showsPercentage, isTrue);

    cubit.setIndex(CorrectionIndex.ipca);
    expect(cubit.state.showsPercentage, isFalse);
  });

  test('troca de índice mensal para diário muda a granularidade', () {
    cubit.setIndex(CorrectionIndex.ipca);
    expect(cubit.state.dateGranularity, DateGranularity.month);

    cubit.setIndex(CorrectionIndex.cdi);
    expect(cubit.state.dateGranularity, DateGranularity.day);
  });

  test('showsCurrencyWarning verdadeiro para 06/1994 e falso para 07/1994', () {
    cubit.setIndex(CorrectionIndex.ipca);
    cubit.initialDate.text = '06/1994';
    expect(cubit.state.showsCurrencyWarning, isTrue);

    cubit.initialDate.text = '07/1994';
    expect(cubit.state.showsCurrencyWarning, isFalse);
  });

  test('data inicial e final não podem ser maiores que a data atual', () {
    cubit.setIndex(CorrectionIndex.ipca);

    final nextMonth = DateTime.now().add(const Duration(days: 32));
    final nextMonthText =
        '${nextMonth.month.toString().padLeft(2, '0')}/${nextMonth.year}';

    cubit.initialDate.text = nextMonthText;
    cubit.finalDate.text = nextMonthText;

    expect(
      cubit.state.fieldErrors[ValueCorrectionField.initialDate],
      'A data inicial não pode ser superior à data atual.',
    );
    expect(
      cubit.state.fieldErrors[ValueCorrectionField.finalDate],
      'A data final não pode ser superior à data atual.',
    );
  });

  test(
    'a data mínima acompanha a disponibilidade e a granularidade do índice',
    () {
      cubit.setIndex(CorrectionIndex.ipcaE);
      cubit.initialDate.text = '12/1991';
      cubit.finalDate.text = '01/1992';

      expect(
        cubit.state.fieldErrors[ValueCorrectionField.initialDate],
        'O índice IPCA-E (IBGE) possui dados a partir de 01/1992.',
      );

      cubit.setIndex(CorrectionIndex.igpM);
      cubit.initialDate.text = '04/2021';
      cubit.finalDate.text = '04/2021';

      expect(cubit.state.fieldErrors[ValueCorrectionField.initialDate], isNull);
      expect(cubit.state.canCalculate, isTrue);
    },
  );

  test('o período aceita exatamente dez anos e rejeita qualquer extensão', () {
    cubit.setIndex(CorrectionIndex.ipca);
    cubit.initialDate.text = '01/2010';
    cubit.finalDate.text = '01/2020';

    expect(cubit.state.fieldErrors[ValueCorrectionField.finalDate], isNull);
    expect(cubit.state.canCalculate, isTrue);

    cubit.finalDate.text = '02/2020';

    expect(
      cubit.state.fieldErrors[ValueCorrectionField.finalDate],
      'O período entre as datas não pode ser superior a 10 anos exatos.',
    );
    expect(cubit.state.canCalculate, isFalse);
  });

  test(
    'a mensagem fica no campo que foi editado por último quando a ordem das datas fica inválida',
    () {
      cubit.setIndex(CorrectionIndex.ipca);
      cubit.initialDate.text = '12/2025';
      cubit.finalDate.text = '01/2025';

      expect(cubit.state.fieldErrors[ValueCorrectionField.initialDate], isNull);
      expect(
        cubit.state.fieldErrors[ValueCorrectionField.finalDate],
        'A data final deve ser posterior ou igual à data inicial.',
      );
    },
  );

  test(
    'a mensagem de ordem inválida some quando o campo corrigido fica válido novamente',
    () {
      cubit.setIndex(CorrectionIndex.ipca);
      cubit.initialDate.text = '12/2025';
      cubit.finalDate.text = '01/2025';

      expect(
        cubit.state.fieldErrors[ValueCorrectionField.finalDate],
        'A data final deve ser posterior ou igual à data inicial.',
      );

      cubit.finalDate.text = '12/2025';

      expect(cubit.state.fieldErrors[ValueCorrectionField.initialDate], isNull);
      expect(cubit.state.fieldErrors[ValueCorrectionField.finalDate], isNull);
    },
  );

  test('clear limpa tudo', () {
    cubit.setIndex(CorrectionIndex.cdi);
    cubit.initialDate.text = '01/01/2024';
    cubit.finalDate.text = '31/01/2024';
    cubit.percentage.text = '100';
    cubit.value.text = '123,45';

    cubit.clear();

    expect(cubit.state.index, isNull);
    expect(cubit.initialDate.text, isEmpty);
    expect(cubit.finalDate.text, isEmpty);
    expect(cubit.percentage.text, isEmpty);
    expect(cubit.value.text, isEmpty);
    expect(cubit.state.canCalculate, isFalse);
  });

  test('apagar uma data inválida limpa a mensagem de erro', () {
    cubit.setIndex(CorrectionIndex.ipca);
    cubit.initialDate.text = '99/2024';

    expect(
      cubit.state.fieldErrors[ValueCorrectionField.initialDate],
      isNotNull,
    );

    cubit.initialDate.clear();

    expect(cubit.state.fieldErrors[ValueCorrectionField.initialDate], isNull);
  });
}
