import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_calc/core/errors/messages.dart';
import 'package:real_calc/core/services/result_sharer.dart';
import 'package:real_calc/core/services/share_plus_result_sharer.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/calculator_palette.dart';
import 'package:real_calc/core/themes/calculator_scope.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/core/utils/date_input_formatter.dart';
import 'package:real_calc/core/utils/decimal_input_formatter.dart';
import 'package:real_calc/core/utils/month_year_input_formatter.dart';
import 'package:real_calc/core/widgets/bottom_action_bar.dart';
import 'package:real_calc/core/widgets/calculator_band/calculator_band.dart';
import 'package:real_calc/core/widgets/field_list/field_list.dart';
import 'package:real_calc/core/widgets/field_list/field_row.dart';
import 'package:real_calc/core/widgets/form_notice.dart';
import 'package:real_calc/core/widgets/help_sheet/help_sheet.dart';
import 'package:real_calc/core/widgets/result_details/result_details.dart';
import 'package:real_calc/core/widgets/types/input_field_state.dart';

import '../../domain/entites/value_correction.dart';
import '../../domain/enum/correction_index.dart';
import '../../domain/enum/date_granularity.dart';
import '../cubit/forms/date_parsing/correction_form_date_parser.dart';
import '../cubit/forms/value_correction_form_cubit.dart';
import '../cubit/forms/value_correction_form_state.dart';
import '../cubit/value_correction/value_correction_cubit.dart';
import '../cubit/value_correction/value_correction_state.dart';
import '../utils/correction_result_summary.dart';
import '../utils/correction_statement.dart';
import '../utils/value_correction_share_text.dart';
import '../widgets/correction_index_picker.dart';

typedef _Inputs = ({
  CorrectionIndex? index,
  String initial,
  String end,
  String percentage,
  String value,
});

class ValueCorrectionPage extends StatefulWidget {
  static const title = 'Correção de Valores';
  static const outOfRangeText = 'fora do período';

  final ResultSharer sharer;

  const ValueCorrectionPage({
    super.key,
    this.sharer = const SharePlusResultSharer(),
  });

  @override
  State<ValueCorrectionPage> createState() => _ValueCorrectionPageState();
}

class _ValueCorrectionPageState extends State<ValueCorrectionPage> {
  final _dateParser = CorrectionFormDateParser();
  _Inputs? _calculatedInputs;

  ValueCorrectionFormCubit get _form =>
      BlocProvider.of<ValueCorrectionFormCubit>(context);

  ValueCorrectionCubit get _calculation =>
      BlocProvider.of<ValueCorrectionCubit>(context);

  _Inputs get _inputs => (
    index: _form.state.index,
    initial: _form.initialDate.text,
    end: _form.finalDate.text,
    percentage: _form.percentage.text,
    value: _form.value.text,
  );

  void _calculate() {
    final index = _form.state.index;
    if (!_form.state.canCalculate || index == null) return;
    FocusScope.of(context).unfocus();
    _calculatedInputs = _inputs;
    _calculation.calculate(
      index: index,
      initialDate: _form.initialDate.text,
      finalDate: _form.finalDate.text,
      percentage: _form.percentage.text,
      value: _form.value.text,
    );
  }

  void _clear() {
    final snapshot = _inputs;
    final hadResult = _calculation.state is ValueCorrectionCalculated;
    FocusScope.of(context).unfocus();
    _form
      ..clear()
      ..setIndex(snapshot.index ?? CorrectionIndex.ipca);
    _calculation.reset();
    _calculatedInputs = null;

    showFieldsClearedSnackBar(
      context,
      onUndo: () {
        _form
          ..setIndex(snapshot.index ?? CorrectionIndex.ipca)
          ..initialDate.text = snapshot.initial
          ..finalDate.text = snapshot.end
          ..percentage.text = snapshot.percentage
          ..value.text = snapshot.value;
        if (hadResult) _calculate();
      },
    );
  }

  void _openIndexPicker(CorrectionIndex? selected) {
    showCorrectionIndexPicker(
      context,
      selectedIndex: selected,
      onSelected: _form.setIndex,
    );
  }

  bool _isBeforeSeries(String text, CorrectionIndex index) {
    final date = _dateParser.parse(text, index.granularity);
    return date != null && date.isBefore(index.minimumInputDate);
  }

  String _supportText(CorrectionIndex index) {
    final initial = _dateParser.parse(
      _form.initialDate.text,
      index.granularity,
    );
    final end = _dateParser.parse(_form.finalDate.text, index.granularity);
    if (initial == null ||
        end == null ||
        initial.isAfter(end) ||
        initial.isBefore(index.minimumInputDate)) {
      return index.sinceSentence;
    }
    return '${correctionDuration(index, initial, end)}. '
        '${index.sinceSentence}';
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScope(
      kind: CalculatorKind.correction,
      child: BlocBuilder<ValueCorrectionFormCubit, ValueCorrectionFormState>(
        builder: (context, formState) =>
            BlocBuilder<ValueCorrectionCubit, ValueCorrectionState>(
              builder: (context, calculation) =>
                  _buildPage(context, formState, calculation),
            ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    ValueCorrectionFormState formState,
    ValueCorrectionState calculation,
  ) {
    final index = formState.index ?? CorrectionIndex.ipca;
    final isCurrent = _calculatedInputs == _inputs;
    final isLoading = calculation is ValueCorrectionLoading;
    final ValueCorrection? result =
        isCurrent && calculation is ValueCorrectionCalculated
        ? calculation.result
        : null;
    final error = isCurrent && calculation is ValueCorrectionError
        ? calculation.message
        : null;
    final offline = error == ServerErrorMessages.connectionError.message;

    final initialOut = _isBeforeSeries(_form.initialDate.text, index);
    final endOut = _isBeforeSeries(_form.finalDate.text, index);
    final outOfRange = initialOut || endOut;
    final otherWarning =
        !outOfRange && formState.warningBannerMessage.isNotEmpty
        ? formState.warningBannerMessage
        : null;

    final isMonthly = index.granularity == DateGranularity.month;
    final dateFormatter = isMonthly
        ? MonthYearInputFormatter()
        : DateInputFormatter();
    final dateHint = isMonthly ? '01/2023' : '01/01/2023';

    FieldRow dateRow({
      required String label,
      required ValueCorrectionField field,
      required bool beforeSeries,
    }) {
      final fieldError = formState.fieldErrors[field];
      final hasError = beforeSeries || fieldError != null;
      return FieldRow(
        key: ValueKey(field),
        label: label,
        controller: _form.controllerFor(field),
        hint: dateHint,
        keyboardType: TextInputType.number,
        inputFormatters: [dateFormatter],
        state: hasError ? InputFieldState.error : InputFieldState.neutral,
        errorText: beforeSeries
            ? ValueCorrectionPage.outOfRangeText
            : fieldError,
      );
    }

    return Scaffold(
      body: Column(
        children: [
          CalculatorBand(
            title: ValueCorrectionPage.title,
            statement: correctionStatement(
              index: index,
              result: result,
              outOfRange: outOfRange,
              offline: offline,
            ),
            onHelp: () => showHelpSheet(context, CalculatorKind.correction),
            onClear: _clear,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AbsorbPointer(
                    absorbing: isLoading,
                    child: FieldList(
                      children: [
                        FieldRow.selection(
                          key: const ValueKey(
                            ValueCorrectionField.selectedIndex,
                          ),
                          label: 'Índice',
                          value: index.label,
                          onTap: () => _openIndexPicker(formState.index),
                        ),
                        dateRow(
                          label: 'De',
                          field: ValueCorrectionField.initialDate,
                          beforeSeries: initialOut,
                        ),
                        dateRow(
                          label: 'Até',
                          field: ValueCorrectionField.finalDate,
                          beforeSeries: endOut,
                        ),
                        if (formState.showsPercentage)
                          FieldRow(
                            key: const ValueKey(
                              ValueCorrectionField.percentage,
                            ),
                            label: 'Percentual',
                            unit: '% do CDI',
                            hint: '100,00',
                            controller: _form.percentage,
                            inputFormatters: [DecimalInputFormatter()],
                            state:
                                formState.fieldErrors[ValueCorrectionField
                                        .percentage] ==
                                    null
                                ? InputFieldState.neutral
                                : InputFieldState.error,
                            errorText: formState
                                .fieldErrors[ValueCorrectionField.percentage],
                          ),
                        FieldRow(
                          key: const ValueKey(ValueCorrectionField.value),
                          label: 'Valor',
                          prefix: 'R\$',
                          secondLine: 'opcional',
                          hint: '0,00',
                          controller: _form.value,
                          inputFormatters: [DecimalInputFormatter()],
                        ),
                      ],
                    ),
                  ),
                  _buildSupport(index),
                  if (outOfRange)
                    _NoticeWithAction(
                      notice: FormNotice(
                        title: 'Data fora do período',
                        message: index.availabilitySentence,
                        isError: true,
                      ),
                      actionLabel: 'Usar ${index.availableFromInputLabel}',
                      onAction: () {
                        if (initialOut) {
                          _form.initialDate.text =
                              index.availableFromInputLabel;
                        }
                        if (endOut) {
                          _form.finalDate.text = index.availableFromInputLabel;
                        }
                      },
                    )
                  else if (otherWarning != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Período fora do limite',
                        message: otherWarning,
                      ),
                    )
                  else if (offline)
                    _NoticeWithAction(
                      notice: const FormNotice(
                        title: 'Sem conexão',
                        message:
                            'Não foi possível buscar os dados no Banco '
                            'Central.',
                        isError: true,
                      ),
                      actionLabel: 'Tentar de novo',
                      onAction: _calculate,
                    )
                  else if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: FormNotice(
                        title: 'Não foi possível corrigir',
                        message: error,
                        isError: true,
                      ),
                    ),
                  if (result != null)
                    ResultDetails(summary: correctionResultSummary(result)),
                ],
              ),
            ),
          ),
          BottomActionBar(
            primaryLabel: 'Corrigir valor',
            isLoading: isLoading,
            onPrimary: formState.canCalculate ? _calculate : null,
            onShare: result == null
                ? null
                : (origin) => widget.sharer.share(
                    buildShareText(result),
                    origin: origin,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupport(CorrectionIndex index) {
    final text = _supportText(index);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.of(context).textSecondary,
        ),
      ),
    );
  }
}

class _NoticeWithAction extends StatelessWidget {
  final FormNotice notice;
  final String actionLabel;
  final VoidCallback onAction;

  const _NoticeWithAction({
    required this.notice,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final palette = CalculatorScope.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          notice,
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: palette.text,
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                textStyle: AppTextStyles.rowLabel.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
