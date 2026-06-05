import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/routes/app_routes.dart';

import 'financing/module.dart';

class AppModule extends Module {
  @override
  void binds(Injector i) {}
  
  @override
  void exportedBinds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.module(AppRoutes.home, module: FinancingModule());
  }
}