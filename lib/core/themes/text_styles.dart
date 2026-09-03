import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

class AppTextStyles {
  static final TextStyle _base = GoogleFonts.manrope();
  static final TextStyle _baseWhite = _base.copyWith(color: Colors.white);

  // Headlines — mantidos, ainda usados pela TextTheme padrão do Material
  // (dialogs, snackbars etc.) mesmo com o header customizado nas telas.
  static final TextStyle headlineLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static final TextStyle headlineMedium = _baseWhite.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Body — mantidos sem alteração, `bodyLarge` já é o tamanho correto
  // usado nos valores de input pelo InputForms.
  static final TextStyle bodyLarge = _base.copyWith(fontSize: 16);
  static final TextStyle bodyMedium = _base.copyWith(fontSize: 14);
  static final TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Componentes gerais — mantidos. errorBannerText já usa ColorTokens.error,
  // só depende da cor em si ser atualizada (ColorTokens), não do estilo.
  static final TextStyle helpCardMessage = _base.copyWith(
    fontSize: 14,
    color: ColorTokens.textPrimary,
    fontWeight: FontWeight.w400,
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

  // Card de métrica (Selic) — NOVO. Substitui highlightCardTitle/
  // highlightCardSubtitle/highlightCardButton, que eram específicos do
  // HighlightCard antigo (removido). Cor não é fixada aqui porque muda
  // conforme o estado (amber padrão, verde/vermelho em variação futura);
  // aplicar via .copyWith(color: ...) no componente.
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
    fontSize: 11,
    color: ColorTokens.textHint,
  );

  // Badge de estado do campo ("vazio" / "calculado" / "resultado") — NOVO.
  // Sem cor fixa: cada estado (amber/verde/vermelho) aplica a própria cor.
  static final TextStyle stateBadge = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // MenuCard
  static final TextStyle menuCardTitle = _baseWhite.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardTitleCompact = _baseWhite.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardDescription = _baseWhite.copyWith(
    fontSize: 10,
    height: 1.1,
  );
  // Corrigido: estava em 9px, abaixo do mínimo legível (11px).
  static final TextStyle menuCardDescriptionCompact = _baseWhite.copyWith(
    fontSize: 11,
    height: 1.1,
  );

  // MenuCard — variante featured (tile full-width, texto um pouco maior
  // por ter mais espaço horizontal disponível). NOVO.
  static final TextStyle menuCardTitleFeatured = _baseWhite.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static final TextStyle menuCardDescriptionFeatured = _base.copyWith(
    fontSize: 12,
    color: ColorTokens.textSecondary,
  );

  // Home
  static final TextStyle appName = _baseWhite.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  // Cor movida pra dentro do estilo (era aplicada com .withValues(alpha: 0.4)
  // no call site em home_page.dart) — evita repetir o ajuste de opacidade
  // toda vez que o label for usado.
  static final TextStyle sectionHeader = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: ColorTokens.textSecondary,
  );
  static final TextStyle historyItem = _baseWhite.copyWith(fontSize: 14);
}