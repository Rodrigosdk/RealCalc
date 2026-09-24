import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/module.dart';

import '../../core/routes/app_routes.dart';
import 'presentation/pages/value_correction_page.dart';

class ValueCorrectionModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.base, child: (_) => ValueCorrectionPage());
  }
}
