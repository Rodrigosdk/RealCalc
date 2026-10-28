import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_calc/core/themes/app_colors.dart';
import 'package:real_calc/core/themes/spacing.dart';
import 'package:real_calc/core/themes/text_styles.dart';
import 'package:real_calc/modules/metrics/domain/entites/metric.dart';

import '../cubit/selic_cubit.dart';
import 'sparkline_painter.dart';

enum SelicPeriod {
  months12('12 meses', 12),
  years5('5 anos', 60);

  final String label;
  final int months;

  const SelicPeriod(this.label, this.months);
}

final _rateFormat = NumberFormat('#,##0.00', 'pt_BR');

class SelicBand extends StatefulWidget {
  static const chartHeight = 40.0;

  final SelicState state;
  final VoidCallback onRetry;
  final DateTime Function() now;

  const SelicBand({
    super.key,
    required this.state,
    required this.onRetry,
    this.now = DateTime.now,
  });

  @override
  State<SelicBand> createState() => _SelicBandState();
}

class _SelicBandState extends State<SelicBand> {
  SelicPeriod _period = SelicPeriod.months12;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final metric = state.metric;

    if (metric == null) {
      return state is SelicError
          ? _Unavailable(onRetry: widget.onRetry)
          : const _Skeleton();
    }

    return _MetricView(
      metric: metric,
      period: _period,
      offline: state is SelicError,
      today: widget.now(),
      onPeriodChanged: (period) => setState(() => _period = period),
      onRetry: widget.onRetry,
    );
  }
}

class _MetricView extends StatelessWidget {
  final Metric metric;
  final SelicPeriod period;
  final bool offline;
  final DateTime today;
  final ValueChanged<SelicPeriod> onPeriodChanged;
  final VoidCallback onRetry;

  const _MetricView({
    required this.metric,
    required this.period,
    required this.offline,
    required this.today,
    required this.onPeriodChanged,
    required this.onRetry,
  });

  List<double> get _points {
    final dates = metric.sparklineDates;
    final lastDate = metric.lastDate;
    if (dates.length != metric.sparklineData.length || lastDate == null) {
      return metric.sparklineData;
    }
    final from = DateTime(
      lastDate.year,
      lastDate.month - period.months,
      lastDate.day,
    );
    return [
      for (var i = 0; i < dates.length; i++)
        if (!dates[i].isBefore(from)) metric.sparklineData[i],
    ];
  }

  String get _rate => '${_rateFormat.format(metric.anualRate)}%';

  String get _variation {
    final change = metric.variationPercent.abs();
    if (change == 0) return 'Sem mudança em relação à anterior';
    final unit = change < 2 ? 'ponto' : 'pontos';
    return '${_rateFormat.format(change)} $unit em relação à anterior';
  }

  String get _updated {
    final lastDate = metric.lastDate;
    if (lastDate == null || DateUtils.isSameDay(lastDate, today)) {
      return 'Fonte: Banco Central, atualizada hoje.';
    }
    String two(int value) => value.toString().padLeft(2, '0');
    return 'Fonte: Banco Central, atualizada em '
        '${two(lastDate.day)}/${two(lastDate.month)}.';
  }

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.of(context).onBandSoft;
    final change = metric.variationPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              'Taxa Selic hoje',
              style: AppTextStyles.bandKicker.copyWith(color: Colors.white),
            ),
            if (offline)
              _OfflineTag(color: soft)
            else
              _PeriodSelector(selected: period, onChanged: onPeriodChanged),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Opacity(
          opacity: offline ? 0.5 : 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _rate,
                  style: AppTextStyles.bandStatement.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'ao ano',
                  style: AppTextStyles.bandSub.copyWith(color: soft),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            if (change != 0) ...[
              Icon(
                change > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Text(
                _variation,
                style: AppTextStyles.bandSub.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          image: true,
          label:
              'Gráfico da Selic nos últimos ${period.label}, '
              'valor atual $_rate ao ano',
          child: SizedBox(
            height: SelicBand.chartHeight,
            width: double.infinity,
            child: CustomPaint(
              painter: SparklinePainter(
                data: _points,
                color: Colors.white.withValues(alpha: offline ? 0.5 : 1),
                strokeWidth: 1.75,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (offline)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            children: [
              Text(
                'Mostrando o último valor salvo.',
                style: AppTextStyles.caption.copyWith(color: soft),
              ),
              _Link(label: 'Atualizar', onTap: onRetry),
            ],
          )
        else
          Text(_updated, style: AppTextStyles.caption.copyWith(color: soft)),
      ],
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final SelicPeriod selected;
  final ValueChanged<SelicPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.of(context).onBandSoft;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final period in SelicPeriod.values)
          Semantics(
            button: true,
            selected: period == selected,
            child: InkWell(
              onTap: () => onChanged(period),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: period == selected
                                ? Colors.white
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        period.label,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: period == selected ? Colors.white : soft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OfflineTag extends StatelessWidget {
  final Color color;

  const _OfflineTag({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          'sem conexão',
          style: AppTextStyles.caption.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Link({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  final VoidCallback onRetry;

  const _Unavailable({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.of(context).onBandSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off, size: 22, color: soft),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Selic indisponível',
          style: AppTextStyles.screenTitle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Sem conexão com o Banco Central.',
          style: AppTextStyles.bandSub.copyWith(color: soft),
        ),
        _Link(label: 'Tentar de novo', onTap: onRetry),
      ],
    );
  }
}

class _Skeleton extends StatefulWidget {
  const _Skeleton();

  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando a taxa Selic',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final color = Colors.white.withValues(
            alpha: 0.10 + 0.10 * _controller.value,
          );
          Widget block(double width, double height) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              block(120, 16),
              const SizedBox(height: 12),
              block(180, 44),
              const SizedBox(height: 10),
              block(220, 14),
              const SizedBox(height: AppSpacing.md),
              block(double.infinity, SelicBand.chartHeight),
              const SizedBox(height: AppSpacing.md),
              block(200, 12),
            ],
          );
        },
      ),
    );
  }
}
