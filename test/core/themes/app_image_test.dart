import 'package:flutter_test/flutter_test.dart';
import 'package:real_calc/core/themes/app_image.dart';

void main() {
  group('AppImage -', () {
    test('Deve retornar o caminho da imagem PNG do ícone do aplicativo', () {
      final result = AppImage.appIcon(AppImageType.png);

      expect(result, 'assets/branding/app_icon.png');
    });

    test('Deve retornar o caminho da imagem SVG do ícone do aplicativo', () {
      final result = AppImage.appIcon(AppImageType.svg);

      expect(result, 'assets/branding/app_icon.svg');
    });
  });

  group('AppImageType -', () {
    test('Deve retornar o valor correto para o tipo de imagem PNG', () {
      expect(AppImageType.png.value, 'png');
    });

    test('Deve retornar o valor correto para o tipo de imagem SVG', () {
      expect(AppImageType.svg.value, 'svg');
    });
  });
}
