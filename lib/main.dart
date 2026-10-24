import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'modules/app_module.dart';
import 'modules/app_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['Manrope'],
      await rootBundle.loadString('assets/fonts/Manrope-OFL.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      ['Bricolage Grotesque'],
      await rootBundle.loadString('assets/fonts/Bricolage-Grotesque-OFL.txt'),
    );
  });
  await initializeDateFormatting('pt_BR', null);

  runApp(
    ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ),
  );
}
