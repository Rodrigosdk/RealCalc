import 'package:flutter/material.dart';
import 'package:real_calc/core/widgets/app_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/themes/theme_cubit.dart';

/// Botão que alterna entre o tema claro e o escuro.
///
/// Mostra a lua no tema claro e o sol no escuro, sem fundo. A cor padrão é
/// branca, pensada para a faixa colorida da tela inicial (#119).
class ThemeToggleButton extends StatelessWidget {
  static const double touchSize = 44;

  final Color color;

  const ThemeToggleButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final label = isDark
        ? 'Mudar para o modo claro'
        : 'Mudar para o modo escuro';

    return MergeSemantics(
      child: Semantics(
        label: label,
        child: SizedBox.square(
          dimension: touchSize,
          child: IconButton(
            onPressed: () => context.read<ThemeCubit>().toggle(brightness),
            padding: EdgeInsets.zero,
            color: color,
            icon: AppIcon(isDark ? AppIcons.sun : AppIcons.moon, size: 22),
          ),
        ),
      ),
    );
  }
}
