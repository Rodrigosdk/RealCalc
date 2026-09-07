import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/modules/home/presentation/cubit/greeting_cubit.dart';

void main() {
  group('GreetingCubit', () {
    test('retorna Bom dia entre 6h e 11h', () {
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 6)),
        'Bom dia',
      );
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 11, 59)),
        'Bom dia',
      );
    });

    test('retorna Boa tarde entre 12h e 17h', () {
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 12)),
        'Boa tarde',
      );
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 17, 59)),
        'Boa tarde',
      );
    });

    test('retorna Boa noite fora do periodo diurno', () {
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 5, 59)),
        'Boa noite',
      );
      expect(
        GreetingCubit.getGreetingByTime(DateTime(2026, 1, 1, 18)),
        'Boa noite',
      );
    });

    test('inicializa com a saudacao atual', () {
      final cubit = GreetingCubit();

      expect(cubit.state, isIn(const ['Bom dia', 'Boa tarde', 'Boa noite']));
      cubit.close();
    });
  });
}