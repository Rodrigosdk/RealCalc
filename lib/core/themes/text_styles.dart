import 'package:flutter/material.dart';
import 'color_tokens.dart';

class AppTextStyles {
  static const String manropeFamily = 'Manrope';
  static const String bricolageGrotesqueFamily = 'Bricolage Grotesque';

  static final TextStyle _base = const TextStyle(
    fontFamily: manropeFamily,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle _baseWhite = _base.copyWith(color: Colors.white);

  // Estilos de destaque e componentes da direção Vibrante minimalista.
  // As cores são definidas pelo componente ou tema que utiliza cada estilo.
  static final TextStyle bandStatement = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
  );
  static final TextStyle screenTitle = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
  );
  static final TextStyle sheetTitle = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static final TextStyle exampleValue = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  static final TextStyle wordmark = const TextStyle(
    fontFamily: bricolageGrotesqueFamily,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static final TextStyle bandKicker = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle bandSub = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle headerTitle = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle rowLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle rowValue = TextStyle(
    fontFamily: manropeFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle rowUnit = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle rowState = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle listTitle = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );
  static final TextStyle listDesc = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle sectionLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle detailLabel = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle detailValue = TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle button = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
  static final TextStyle pill = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );
  static final TextStyle body = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static final TextStyle caption = const TextStyle(
    fontFamily: manropeFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Títulos mantidos para uso no TextTheme padrão do Material
  // (caixas de diálogo, mensagens etc.), além dos cabeçalhos personalizados.
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static final TextStyle headlineMedium = _baseWhite.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Estilos de texto mantidos sem alteração. `bodyLarge` já tem o tamanho
  // correto para os valores de entrada dos formulários.
  static final TextStyle bodyLarge = _base.copyWith(fontSize: 16);
  static final TextStyle bodyMedium = _base.copyWith(fontSize: 14);
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Estilos gerais mantidos. `errorBannerText` já usa ColorTokens.error;
  // a cor é definida em ColorTokens, sem alterar o estilo.
  static final TextStyle helpCardMessage = _base.copyWith(
    fontSize: 14,
    color: ColorTokens.textPrimary,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle inputHelperText = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textHint,
  );
  static final TextStyle errorBannerText = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: ColorTokens.error,
  );

  // Cartão de métrica (Selic). Substitui os estilos específicos do antigo
  // cartão de destaque, que foi removido. A cor varia conforme o estado
  // (âmbar, verde ou vermelho) e é aplicada no componente com `.copyWith`.
  static final TextStyle metricLabel = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textSecondary,
  );
  static final TextStyle metricValue = _base.copyWith(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.6,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final TextStyle metricCaption = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textHint,
  );

  // Indicador de estado do campo ("vazio", "calculado" ou "resultado").
  // Sem cor fixa: cada estado aplica sua própria cor.
  static final TextStyle stateBadge = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Cartão do menu.
  static final TextStyle menuCardTitle = _baseWhite.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardTitleCompact = _baseWhite.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardDescription = _baseWhite.copyWith(
    fontSize: 12,
    height: 1.2,
  );
  static final TextStyle menuCardDescriptionCompact = _baseWhite.copyWith(
    fontSize: 12,
    height: 1.2,
  );

  // Cartão do menu em destaque, com texto maior por ter mais espaço.
  static final TextStyle menuCardTitleFeatured = _baseWhite.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardDescriptionFeatured = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textSecondary,
  );

  // Tela inicial.
  static final TextStyle appName = _baseWhite.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  // Cor definida no próprio estilo, antes aplicada no local de uso da tela
  // inicial. Isso evita repetir o ajuste de opacidade em cada utilização.
  static final TextStyle sectionHeader = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: ColorTokens.textSecondary,
  );
  static final TextStyle historyItem = _baseWhite.copyWith(fontSize: 14);
}