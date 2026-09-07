import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/modules/home/presentation/page/page.dart';

import '../../core/routes/app_routes.dart';
import '../metrics/module.dart';
import 'presentation/cubit/greeting_cubit.dart';
import 'presentation/cubit/selic_cubit.dart';

class HomeModule extends Module {
  @override
  List<Module> get imports => [MetricsModule()];

  @override
  void binds(i) {
    i.add(GreetingCubit.new);
    i.add(SelicCubit.new);
  }

  @override
  void routes(r) {
    r.child(
      AppRoutes.base,
      child: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => Modular.get<GreetingCubit>()),
          BlocProvider(create: (_) => Modular.get<SelicCubit>()..load()),
        ],
        child: const HomePage(),
      ),
    );
  }
}
