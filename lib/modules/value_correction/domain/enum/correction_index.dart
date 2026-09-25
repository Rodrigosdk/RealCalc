import 'correction_group.dart';
import 'date_granularity.dart';
import 'series_kind.dart';

enum CorrectionIndex {
  ipca(
    label: 'IPCA (IBGE)',
    group: CorrectionGroup.inflation,
    sgsCode: 433,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1980,
    fromMonth: 1,
  ),
  inpc(
    label: 'INPC (IBGE)',
    sgsCode: 188,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1979,
    fromMonth: 7,
  ),
  ipcaE(
    label: 'IPCA-E (IBGE)',
    sgsCode: 10764,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1992,
    fromMonth: 1,
  ),
  igpDi(
    label: 'IGP-DI (FGV)',
    sgsCode: 190,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1944,
    fromMonth: 2,
  ),
  igpM(
    label: 'IGP-M (FGV)',
    sgsCode: 28655,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 2021,
    fromMonth: 4,
    fromDay: 12,
  ),
  ipcBrasil(
    label: 'IPC-Brasil (FGV)',
    sgsCode: 191,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1990,
    fromMonth: 1,
  ),
  ipcSp(
    label: 'IPC-SP (FIPE)',
    sgsCode: 193,
    group: CorrectionGroup.inflation,
    kind: SeriesKind.monthlyVariation,
    granularity: DateGranularity.month,
    fromYear: 1942,
    fromMonth: 11,
  ),
  cdi(
    label: 'CDI',
    sgsCode: 12,
    group: CorrectionGroup.interest,
    kind: SeriesKind.dailyRate,
    granularity: DateGranularity.day,
    fromYear: 1994,
    fromMonth: 10,
  ),
  selic(
    label: 'Selic',
    sgsCode: 11,
    group: CorrectionGroup.interest,
    kind: SeriesKind.dailyRate,
    granularity: DateGranularity.day,
    fromYear: 1986,
    fromMonth: 6,
    fromDay: 4,
  ),
  tr(
    label: 'TR',
    sgsCode: 226,
    group: CorrectionGroup.interest,
    kind: SeriesKind.periodRate,
    granularity: DateGranularity.day,
    fromYear: 1994,
    fromMonth: 7,
  ),
  poupancaNova(
    label: 'Poupança Nova',
    sgsCode: 195,
    group: CorrectionGroup.savings,
    kind: SeriesKind.periodRate,
    granularity: DateGranularity.month,
    fromYear: 2012,
    fromMonth: 5,
    fromDay: 4,
  ),
  poupancaVelha(
    label: 'Poupança Velha',
    sgsCode: 25,
    group: CorrectionGroup.savings,
    kind: SeriesKind.periodRate,
    granularity: DateGranularity.month,
    fromYear: 1986,
    fromMonth: 7,
  ),
  taxaLegal(
    label: 'Taxa Legal',
    sgsCode: 29543,
    group: CorrectionGroup.interest,
    kind: SeriesKind.simpleMonthlyRate,
    granularity: DateGranularity.day,
    fromYear: 2024,
    fromMonth: 8,
    fromDay: 30,
  );

  const CorrectionIndex({
    required this.label,
    required this.group,
    required this.sgsCode,
    required this.kind,
    required this.granularity,
    required this.fromYear,
    required this.fromMonth,
    this.fromDay = 1,
  });

  final String label;
  final CorrectionGroup group;
  final int sgsCode;
  final SeriesKind kind;
  final DateGranularity granularity;
  final int fromYear, fromMonth, fromDay;

  DateTime get availableFrom => DateTime(fromYear, fromMonth, fromDay);
}
