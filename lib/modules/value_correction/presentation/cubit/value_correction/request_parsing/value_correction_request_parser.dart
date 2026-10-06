import '../../../../domain/entites/period.dart';
import '../../../../domain/entites/value_correction.dart';
import '../../../../domain/enum/correction_index.dart';
import '../../../../domain/enum/series_kind.dart';
import '../../forms/date_parsing/i_correction_form_date_parser.dart';
import 'i_value_correction_request_parser.dart';

class ValueCorrectionRequestParser implements IValueCorrectionRequestParser {
  final ICorrectionFormDateParser _dateParser;

  ValueCorrectionRequestParser(this._dateParser);

  @override
  ValueCorrection? parse({
    required CorrectionIndex index,
    required String initialDate,
    required String finalDate,
    required String percentage,
    required String value,
  }) {
    final start = _dateParser.parse(initialDate, index.granularity);
    final end = _dateParser.parse(finalDate, index.granularity);
    if (start == null || end == null) return null;

    final originalValue = _parseNumber(value);
    return ValueCorrection(
      index: index.sgsCode,
      period: Period(initial: start, end: end),
      percentage: _resolvePercentage(index, percentage),
      originalValue: originalValue,
      factor: 1,
      adjustedValue: originalValue,
      variation: 0,
    );
  }

  double _resolvePercentage(CorrectionIndex index, String value) {
    if (index != CorrectionIndex.cdi) {
      return index.kind == SeriesKind.dailyRate ? 100 : 0;
    }
    final parsed = _parseNumber(value);
    return parsed != null && parsed > 0 ? parsed : 100;
  }

  double? _parseNumber(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }
}
