import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/app_colors.dart';

/// Lista de campos: uma coluna com linha `hairline` no topo, sem cartão,
/// sombra ou ícones. Cada [FieldRow] desenha a própria linha de baixo.
class FieldList extends StatelessWidget {
  final List<Widget> children;

  const FieldList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
