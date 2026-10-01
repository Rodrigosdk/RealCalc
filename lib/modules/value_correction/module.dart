import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/module.dart';

import '../../core/routes/app_routes.dart';
import 'domain/repositories/i_correction_series_repository.dart';
import 'domain/validation/value_correction_validation.dart';
import 'infrastructure/repositories/sgs_repository.dart';
import 'presentation/pages/value_correction_page.dart';
import 'use_cases/calculate_value_correction.dart';
import 'use_cases/i_calculate_value_correction.dart';

class ValueCorrectionModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<ValueCorrectionValidation>(ValueCorrectionValidation.new);
    i.addLazySingleton<ICorrectionSeriesRepository>(SgsRepository.new);
    i.addLazySingleton<ICalculateValueCorrection>(CalculateValueCorrection.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(AppRoutes.base, child: (_) => ValueCorrectionPage());
  }
}
