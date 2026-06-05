import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_calc/modules/app_module.dart';
import 'package:real_calc/modules/app_widget.dart';
import 'package:real_calc/modules/financing/presentation/pages/page.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    Modular.destroy();
  });

  group('AppWidget & AppModule - Integração de Rotas', () {
    testWidgets('Deve inicializar o AppWidget e carregar a FinancingPage na rota padrão', (tester) async {
      await tester.pumpWidget(
        ModularApp(
          module: AppModule(),
          child: const AppWidget(),
        ),
      );

      // Aguarda a resolução assíncrona das rotas e animações iniciais
      await tester.pumpAndSettle();

      // Valida que o MaterialApp.router processou a árvore e renderizou a página com sucesso
      expect(find.byType(FinancingPage), findsOneWidget);
    });
  });
}
