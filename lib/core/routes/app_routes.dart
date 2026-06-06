class AppRoutes {
  static const String base = '/';
  
  // Absolutos
  static const String home = base;

  // Segmentos relativos (usados dentro do HomeModule)
  static const String financingSegment = 'financing';
  static const String futureValueSegment = 'future_value';
  static const String depositsSegment = 'deposits';
  static const String correctionSegment = 'correction';
  static const String historySegment = 'history';
  static const String profileSegment = 'profile';

  // Absolutos para navegação
  static const String financing = '/home/$financingSegment';
  static const String futureValue = '/home/$futureValueSegment';
  static const String deposits = '/home/$depositsSegment';
  static const String correction = '/home/$correctionSegment';
  static const String history = '/home/$historySegment';
  static const String profile = '/home/$profileSegment';
}