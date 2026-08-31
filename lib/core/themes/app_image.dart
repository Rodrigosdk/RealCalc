class AppImage {
  static const String _branding = 'assets/branding/';
  static const String _appIcon = 'app_icon';

  /// Retorna o caminho para a imagem do ícone do aplicativo com base no [AppImageType] especificado.
  static String appIcon(AppImageType type) {
    switch (type) {
      case AppImageType.png:
        return '$_branding$_appIcon.png';
      case AppImageType.svg:
        return '$_branding$_appIcon.svg';
    }
  }
}

/// Enum que representa os tipos de imagens de aplicativo disponíveis.
enum AppImageType {
  png('png'),
  svg('svg');

  final String value;

  const AppImageType(this.value);
}