import 'package:flutter/material.dart';
import 'package:real_calc/core/themes/extensions/metric_card_theme.dart';
import 'package:real_calc/modules/home/domain/enum/metric_status.dart';

import '../../domain/enum/metric_trend.dart';
import 'sparkline_painter.dart';


/// Card de métrica que exibe a taxa Selic atual, sua variação recente
/// e uma mini sparkline de tendência. Componente puramente apresentacional
/// — quem decide o status (loading/data/offline) é o cubit que consome a
/// API do BCB; esse widget só sabe desenhar cada um dos 3 estados.
class MetricCard extends StatelessWidget {
  final MetricStatus status;
  final double? ratePercent;
  final double? variationPercent;
  final List<double> sparklineData;
  final String caption;
  final VoidCallback? onTap;

  /// Estado de carregamento — usado enquanto a requisição está em voo.
  const MetricCard.loading({super.key})
      : status = MetricStatus.loading,
        ratePercent = null,
        variationPercent = null,
        sparklineData = const [],
        caption = '',
        onTap = null;

  /// Estado com dado disponível (o fluxo normal).
  const MetricCard.data({
    super.key,
    required this.ratePercent,
    required this.variationPercent,
    required this.sparklineData,
    required this.caption,
    this.onTap,
  }) : status = MetricStatus.data;

  /// Estado sem conexão. Se `ratePercent` vier preenchido, mostra o
  /// último valor salvo em cache (esmaecido); se vier nulo, mostra um
  /// estado vazio com opção de tentar novamente via `onTap`.
  const MetricCard.offline({
    super.key,
    this.ratePercent,
    this.variationPercent,
    this.sparklineData = const [],
    required this.caption,
    this.onTap,
  }) : status = MetricStatus.offline;

  MetricTrend get _trend {
    final variation = variationPercent ?? 0;
    if (variation > 0) return MetricTrend.up;
    if (variation < 0) return MetricTrend.down;
    return MetricTrend.flat;
  }

  String _formatRate(double rate) => rate.toStringAsFixed(2).replaceAll('.', ',');

  String _formatVariation(double variation) {
    final sign = variation > 0 ? '+' : '';
    return '$sign${variation.toStringAsFixed(2).replaceAll('.', ',')}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<MetricCardTheme>()!;

    switch (status) {
      case MetricStatus.loading:
        return _LoadingCard(theme: theme);
      case MetricStatus.data:
        return _DataCard(
          theme: theme,
          ratePercent: ratePercent!,
          variationPercent: variationPercent!,
          sparklineData: sparklineData,
          caption: caption,
          trend: _trend,
          formatRate: _formatRate,
          formatVariation: _formatVariation,
          onTap: onTap,
        );
      case MetricStatus.offline:
        return _OfflineCard(
          theme: theme,
          ratePercent: ratePercent,
          variationPercent: variationPercent,
          sparklineData: sparklineData,
          caption: caption,
          trend: _trend,
          formatRate: _formatRate,
          formatVariation: _formatVariation,
          onTap: onTap,
        );
    }
  }
}

/// Estado de dado disponível — layout original do card.
class _DataCard extends StatelessWidget {
  final MetricCardTheme theme;
  final double ratePercent;
  final double variationPercent;
  final List<double> sparklineData;
  final String caption;
  final MetricTrend trend;
  final String Function(double) formatRate;
  final String Function(double) formatVariation;
  final VoidCallback? onTap;

  const _DataCard({
    required this.theme,
    required this.ratePercent,
    required this.variationPercent,
    required this.sparklineData,
    required this.caption,
    required this.trend,
    required this.formatRate,
    required this.formatVariation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color trendColor = switch (trend) {
      MetricTrend.up => theme.variationPositiveColor,
      MetricTrend.down => theme.variationNegativeColor,
      MetricTrend.flat => theme.variationNeutralColor,
    };

    final content = Container(
      key: const Key('metric_card_container'),
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Selic atual', style: theme.labelStyle),
                        const SizedBox(width: 8),
                        Container(
                          key: const Key('metric_card_variation_badge'),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: trendColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            formatVariation(variationPercent),
                            style: theme.variationTextStyle
                                .copyWith(color: trendColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: formatRate(ratePercent),
                        style: theme.valueStyle,
                        children: [
                          TextSpan(text: '% a.a.', style: theme.valueUnitStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                key: const Key('metric_card_sparkline'),
                width: 72,
                height: 32,
                child: CustomPaint(
                  painter: SparklinePainter(
                    data: sparklineData,
                    color: trendColor,
                    strokeWidth: theme.sparklineStrokeWidth,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(caption, style: theme.captionStyle),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: content,
    );
  }
}

/// Estado offline — mostra o último valor em cache (esmaecido) se houver,
/// ou um estado vazio com "tentar novamente" se não houver nada salvo.
class _OfflineCard extends StatelessWidget {
  final MetricCardTheme theme;
  final double? ratePercent;
  final double? variationPercent;
  final List<double> sparklineData;
  final String caption;
  final MetricTrend trend;
  final String Function(double) formatRate;
  final String Function(double) formatVariation;
  final VoidCallback? onTap;

  const _OfflineCard({
    required this.theme,
    required this.ratePercent,
    required this.variationPercent,
    required this.sparklineData,
    required this.caption,
    required this.trend,
    required this.formatRate,
    required this.formatVariation,
    this.onTap,
  });

  bool get _hasCachedData => ratePercent != null;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      key: const Key('metric_card_container'),
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
      ),
      child: _hasCachedData ? _cachedContent() : _emptyContent(),
    );

    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.borderRadius),
      child: container,
    );
  }

  Widget _offlineTag() {
    return Container(
      key: const Key('metric_card_offline_tag'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.variationNeutralColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 11, color: theme.variationNeutralColor),
          const SizedBox(width: 4),
          Text(
            'offline',
            style:
                theme.variationTextStyle.copyWith(color: theme.variationNeutralColor),
          ),
        ],
      ),
    );
  }

  Widget _cachedContent() {
    // Valor em cache, mas visualmente esmaecido — deixa claro que não é
    // o dado mais recente, sem esconder a última informação conhecida.
    return Opacity(
      opacity: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Selic atual', style: theme.labelStyle),
              const SizedBox(width: 8),
              _offlineTag(),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: formatRate(ratePercent!),
              style: theme.valueStyle,
              children: [
                TextSpan(text: '% a.a.', style: theme.valueUnitStyle),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(caption, style: theme.captionStyle),
        ],
      ),
    );
  }

  Widget _emptyContent() {
    return Row(
      children: [
        Icon(Icons.wifi_off, size: 18, color: theme.variationNeutralColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(caption, style: theme.captionStyle),
              if (onTap != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Toque para tentar novamente',
                  style: theme.variationTextStyle
                      .copyWith(color: theme.variationNeutralColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Estado de carregamento — placeholders no formato do layout final,
/// com uma animação sutil de pulso pra sinalizar "carregando".
class _LoadingCard extends StatefulWidget {
  final MetricCardTheme theme;

  const _LoadingCard({required this.theme});

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.theme.skeletonColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      key: const Key('metric_card_container'),
      width: double.infinity,
      padding: theme.padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.borderColor),
      ),
      child: FadeTransition(
        opacity: _controller.drive(
          Tween<double>(begin: 0.4, end: 0.85),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(width: 90, height: 12),
                      const SizedBox(height: 10),
                      _bar(width: 130, height: 28),
                    ],
                  ),
                ),
                _bar(width: 72, height: 32),
              ],
            ),
            const SizedBox(height: 12),
            _bar(width: 180, height: 11),
          ],
        ),
      ),
    );
  }
}
