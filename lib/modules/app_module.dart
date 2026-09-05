import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';
import 'package:real_calc/core/module.dart';

import 'financing/module.dart';
import 'future_value/module.dart';
import 'home/module.dart';
import 'regular_deposits/module.dart';

class AppModule extends CoreModule {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.module(AppRoutes.home, module: HomeModule());
    r.module(AppRoutes.financing, module: FinancingModule());
    r.module(AppRoutes.deposits, module: RegularDepositsModule());
    r.module(AppRoutes.futureValue, module: FutureValueModule());
  }
}