  import 'package:flutter_modular/flutter_modular.dart';
  import 'package:real_calc/core/module.dart';

  import 'domain/repositories/selic/i_selic_network_only_repository.dart';
  import 'infrastructure/repositories/selic_repository.dart';
  import 'use_cases/selic/i_selic_use_case.dart';
  import 'use_cases/selic/selic_use_case.dart';
  import 'use_cases/selic/selic_validation.dart';

  class MetricsModule extends Module {
    @override
    List<Module> get imports => [CoreModule()];

    @override
    void binds(Injector i) {
      i.addLazySingleton<ISelicNetworkOnlyRepository>(SelicRepository.new);
      i.addLazySingleton<SelicValidation>(SelicValidation.new);
    }

    @override
    void exportedBinds(Injector i) {
      i.addLazySingleton<ISelicUseCase>(
        () => SelicUseCase(
          i.get<ISelicNetworkOnlyRepository>(),
          i.get<SelicValidation>(),
        ),
      );
    }
  }
