import 'package:real_calc/core/widgets/calculator_band/band_statement.dart';

const shareDisclaimer = 'Simulação feita no RealCalc, sem valor oficial.';

String shareText({
  required String calculator,
  required BandStatement statement,
  required List<(String, String)> lines,
}) {
  final headline = [
    ?statement.kicker,
    statement.isMoney ? 'R\$ ${statement.value}' : statement.value,
  ].join(' ');

  return [
    'RealCalc · $calculator',
    headline,
    ?statement.sub,
    '',
    for (final (label, value) in lines) '$label: $value',
    '',
    shareDisclaimer,
  ].join('\n').replaceAll(String.fromCharCode(0xA0), ' ');
}
