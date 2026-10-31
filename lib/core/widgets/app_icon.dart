import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class AppIcons {
  static const _dir = 'assets/icons';

  static const alert = '$_dir/alert.svg';
  static const arrowDown = '$_dir/arrow_down.svg';
  static const arrowUp = '$_dir/arrow_up.svg';
  static const back = '$_dir/back.svg';
  static const bank = '$_dir/bank.svg';
  static const check = '$_dir/check.svg';
  static const chevronDown = '$_dir/chevron_down.svg';
  static const chevronRight = '$_dir/chevron_right.svg';
  static const close = '$_dir/close.svg';
  static const cycle = '$_dir/cycle.svg';
  static const help = '$_dir/help.svg';
  static const moon = '$_dir/moon.svg';
  static const piggyBank = '$_dir/piggy_bank.svg';
  static const reset = '$_dir/reset.svg';
  static const search = '$_dir/search.svg';
  static const share = '$_dir/share.svg';
  static const sun = '$_dir/sun.svg';
  static const trendingUp = '$_dir/trending_up.svg';
  static const wifiOff = '$_dir/wifi_off.svg';
}

/// Ícone de `assets/icons`; sem cor ou tamanho, segue o [IconTheme], como o
/// [Icon], e por isso funciona dentro de [IconButton].
class AppIcon extends StatelessWidget {
  final String asset;
  final double? size;
  final Color? color;

  const AppIcon(this.asset, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = this.size ?? theme.size ?? 24;
    final color = this.color ?? theme.color ?? Colors.black;

    // Como o Icon: em restrições justas, fica centralizado no tamanho pedido.
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
