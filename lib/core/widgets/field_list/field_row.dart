import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/radius.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';

import '../types/input_field_state.dart';

/// Linha de um campo da [FieldList].
///
/// À esquerda ficam o rótulo e uma segunda linha opcional; à direita, sem
/// quebra, o prefixo, o valor e a unidade. A cor de destaque vem do
/// [CalculatorScope] mais próximo.
///
/// Estados:
/// - neutro;
/// - em edição (com foco): linha de 2px e cursor na cor da calculadora;
/// - [InputFieldState.unknown]: "a descobrir" e pílula "Toque para calcular";
/// - [InputFieldState.calculated]: "calculado para você", ✓ e valor em
///   destaque;
/// - [InputFieldState.error]: linha, valor e segunda linha em `error`;
/// - seleção ([FieldRow.selection]): valor e chevron, abre um seletor.
class FieldRow extends StatefulWidget {
  static const unknownText = 'a descobrir';
  static const calculatedText = 'calculado para você';
  static const calculateText = 'Toque para calcular';

  final String label;

  /// Segunda linha opcional, como "todo mês" ou "opcional". Nos estados
  /// a descobrir e calculado é trocada pelo texto do estado.
  final String? secondLine;

  /// Texto da segunda linha no estado de erro (ex.: "fora do período").
  final String? errorText;

  final InputFieldState state;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? prefix;
  final String? unit;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Chamado ao tocar na linha no estado a descobrir.
  final VoidCallback? onCalculate;

  /// Espaço mantido entre o campo em foco e o teclado.
  final EdgeInsets scrollPadding;

  final String? _selectionValue;
  final VoidCallback? _onSelect;

  const FieldRow({
    super.key,
    required this.label,
    required TextEditingController this.controller,
    this.secondLine,
    this.errorText,
    this.state = InputFieldState.neutral,
    this.focusNode,
    this.prefix,
    this.unit,
    this.hint = '0',
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.inputFormatters,
    this.onChanged,
    this.onCalculate,
    this.scrollPadding = const EdgeInsets.fromLTRB(20, 20, 20, 120),
  }) : _selectionValue = null,
       _onSelect = null;

  /// Linha de seleção (ex.: Índice): mostra o valor e um chevron e chama
  /// [onTap] ao ser tocada.
  const FieldRow.selection({
    super.key,
    required this.label,
    required String value,
    required VoidCallback onTap,
    this.secondLine,
    this.errorText,
    this.state = InputFieldState.neutral,
  }) : _selectionValue = value,
       _onSelect = onTap,
       controller = null,
       focusNode = null,
       prefix = null,
       unit = null,
       hint = '',
       keyboardType = TextInputType.none,
       inputFormatters = null,
       onChanged = null,
       onCalculate = null,
       scrollPadding = EdgeInsets.zero;

  bool get isSelection => _onSelect != null;

  @override
  State<FieldRow> createState() => _FieldRowState();
}

class _FieldRowState extends State<FieldRow> {
  /// Parte máxima da linha ocupada pelo bloco da direita; o resto fica para
  /// o rótulo e a segunda linha, que quebram.
  static const _maxTrailingFraction = 0.65;

  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_rebuild);
    widget.controller?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(FieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_rebuild);
      _focusNode.addListener(_rebuild);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_rebuild);
      widget.controller?.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_rebuild);
    widget.controller?.removeListener(_rebuild);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool get _isUnknown => widget.state == InputFieldState.unknown;
  bool get _isCalculated => widget.state == InputFieldState.calculated;
  bool get _isError => widget.state == InputFieldState.error;
  bool get _isEditing =>
      !widget.isSelection && !_isUnknown && _focusNode.hasFocus;

  void _handleTap() {
    if (widget.isSelection) {
      widget._onSelect!();
    } else if (_isUnknown) {
      widget.onCalculate?.call();
    } else {
      _focusNode.requestFocus();
    }
  }

  CalculatorPalette _palette(BuildContext context) {
    final scoped = CalculatorScope.maybeOf(context);
    if (scoped != null) return scoped;
    final scheme = Theme.of(context).colorScheme;
    return CalculatorPalette(
      solid: scheme.primary,
      onSolid: scheme.onPrimary,
      text: scheme.primary,
    );
  }

  String? get _stateText {
    if (_isError) return widget.errorText ?? widget.secondLine;
    if (_isUnknown) return FieldRow.unknownText;
    if (_isCalculated) return FieldRow.calculatedText;
    return widget.secondLine;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final palette = _palette(context);
    final secondText = _stateText;

    final (lineColor, lineWidth) = switch (true) {
      _ when _isError => (colors.error, 1.5),
      _ when _isUnknown || _isEditing => (palette.solid, 2.0),
      _ => (colors.hairline, 1.0),
    };

    final secondStyle = (_isError || _isUnknown || _isCalculated)
        ? AppTextStyles.rowState.copyWith(
            color: _isError ? colors.error : palette.text,
          )
        : AppTextStyles.caption.copyWith(color: colors.textSecondary);

    final row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: secondText == null
              ? AppSpacing.rowHeight
              : AppSpacing.rowHeightWithSecondLine,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: lineColor, width: lineWidth),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: AppTextStyles.rowLabel.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (secondText != null) ...[
                        const SizedBox(height: 2),
                        Text(secondText, style: secondStyle),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Valor sem quebra: se não couber (tela estreita e fonte grande),
              // diminui inteiro em vez de ser cortado.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * _maxTrailingFraction,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _buildTrailing(context, colors, palette),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isSelection || _isUnknown) {
      final value = widget.isSelection
          ? widget._selectionValue
          : FieldRow.unknownText;
      return Semantics(
        container: true,
        button: true,
        label: [
          widget.label,
          value,
          if (widget.isSelection && secondText != null) secondText,
        ].join(', '),
        onTap: _handleTap,
        excludeSemantics: true,
        child: row,
      );
    }

    // O TextField contribui com o valor; o rótulo junta nome, unidade e
    // estado, na ordem em que o TalkBack deve ler.
    return MergeSemantics(
      child: Semantics(
        label: [widget.label, ?widget.unit, ?secondText].join(', '),
        child: row,
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    AppColors colors,
    CalculatorPalette palette,
  ) {
    if (widget.isSelection) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget._selectionValue!,
            style: AppTextStyles.rowValue.copyWith(
              color: _isError ? colors.error : colors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right, size: 20, color: colors.textSecondary),
        ],
      );
    }

    if (_isUnknown) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: palette.solid,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          FieldRow.calculateText,
          style: AppTextStyles.pill.copyWith(color: palette.onSolid),
        ),
      );
    }

    final valueStyle = AppTextStyles.rowValue.copyWith(
      color: switch (widget.state) {
        InputFieldState.error => colors.error,
        InputFieldState.calculated => palette.text,
        _ => colors.textPrimary,
      },
      fontWeight: _isCalculated ? FontWeight.w800 : null,
    );
    final unitStyle = AppTextStyles.rowUnit.copyWith(
      color: _isError ? colors.error : colors.textSecondary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (_isCalculated) ...[
          Icon(Icons.check, size: 16, color: palette.text),
          const SizedBox(width: 6),
        ],
        if (widget.prefix != null) ...[
          ExcludeSemantics(child: Text(widget.prefix!, style: unitStyle)),
          const SizedBox(width: AppSpacing.xs),
        ],
        // Largura do conteúdo (ou do hint), para prefixo, valor e unidade
        // ficarem colados.
        IntrinsicWidth(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            textAlign: TextAlign.end,
            textInputAction: TextInputAction.done,
            style: valueStyle,
            cursorColor: palette.solid,
            scrollPadding: widget.scrollPadding,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: valueStyle.copyWith(color: colors.textHint),
              isCollapsed: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        if (widget.unit != null) ...[
          const SizedBox(width: AppSpacing.xs),
          ExcludeSemantics(child: Text(widget.unit!, style: unitStyle)),
        ],
      ],
    );
  }
}
