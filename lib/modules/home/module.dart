import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';

import '../../core/routes/app_routes.dart';

class HomeModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(
      AppRoutes.base,
      child: (_) => const HomePage(),
    );
  }
}
