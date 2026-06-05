import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/financing/presentation/cubit/financing_cubit.dart';
import 'package:real_calc/modules/financing/presentation/pages/page.dart';

// Criação do Mock para o Cubit que estava gerando a quebra assíncrona
class MockFinancingCubit extends MockCubit<FinancingState> implements FinancingCubit {}

// Módulo exclusivo de Testes que estende o AppModule real, 
// mas injeta o Mock síncrono para blindar a árvore de widgets
class AppModuleTest extends AppModule {
  final FinancingCubit customCubit;

  AppModuleTest({required this.customCubit});

  @override
  void binds(Injector i) {
    super.binds(i);
    i.addInstance<FinancingCubit>(customCubit);
  }
}

void main() {
  late FinancingCubit mockCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockCubit = MockFinancingCubit();
    when(() => mockCubit.state).thenReturn(FinancingInitial());
    
    Modular.destroy();
  });

  group('AppModule & AppWidget - Testes de Rotas', () {
    testWidgets('Deve inicializar o AppModule e renderizar a rota inicial (FinancingPage)', (tester) async {
      await tester.pumpWidget(
        ModularApp(
          module: AppModuleTest(customCubit: mockCubit), // Usa o módulo de teste injetado
          child: const AppWidget(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FinancingPage), findsOneWidget);
    });

    testWidgets('Deve garantir que a rota mapeada para AppRoutes.home seja acessível', (tester) async {
      await tester.pumpWidget(
        ModularApp(
          module: AppModuleTest(customCubit: mockCubit), // Usa o módulo de teste injetado
          child: const AppWidget(),
        ),
      );
      
      await tester.pumpAndSettle();

      Modular.to.navigate(AppRoutes.home);
      
      await tester.idle();
      await tester.pumpAndSettle();

      expect(find.byType(FinancingPage), findsOneWidget);
    });
  });
}
