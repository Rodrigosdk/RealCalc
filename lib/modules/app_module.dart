import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/module.dart';

import 'financial_calculators/module.dart';
import 'home/module.dart';
import 'value_correction/module.dart';

class AppModule extends CoreModule {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.module(AppRoutes.home, module: HomeModule());
    r.module(AppRoutes.financing, module: FinancialCalculatorsModule());
    r.module(AppRoutes.correction, module: ValueCorrectionModule());
  }
}