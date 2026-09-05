import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/adapter/network/dio/dio_network_adapter.dart';
import 'package:real_calc/core/seed_works/network.dart';

class CoreModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<Dio>(() => Dio());
  }

  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton<Network>(
      () => DioNetworkAdapter(i.get<Dio>()),
    );
  }
}
