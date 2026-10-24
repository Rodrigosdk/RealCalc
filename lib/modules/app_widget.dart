import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/themes/theme_cubit.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) => MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) {
          final colors =
              Theme.of(context).extension<AppColors>() ?? AppColors.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemUiOverlayStyle(colors),
            child: child ?? const SizedBox.shrink(),
          );
        },
        routeInformationParser: Modular.routeInformationParser,
        routerDelegate: Modular.routerDelegate,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}
