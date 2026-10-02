import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/value_correction/domain/enum/correction_index.dart';
import 'package:real_calc/modules/value_correction/domain/enum/date_granularity.dart';
import 'package:real_calc/modules/value_correction/presentation/cubit/forms/value_correction_form_cubit.dart';

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
}
