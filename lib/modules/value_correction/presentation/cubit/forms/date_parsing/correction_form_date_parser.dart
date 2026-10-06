import '../../../../domain/enum/date_granularity.dart';
import 'i_correction_form_date_parser.dart';

class CorrectionFormDateParser implements ICorrectionFormDateParser {
  @override
  DateTime? parse(String value, DateGranularity granularity) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split('/');
    if (granularity == DateGranularity.month) {
      if (parts.length != 2) return null;
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      if (month == null || year == null || month < 1 || month > 12) {
        return null;
      }
      return DateTime(year, month, 1);
    }

    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || month < 1 || month > 12) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  @override
  bool isFutureDate(String value, DateGranularity granularity) {
    final date = parse(value, granularity);
    if (date == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isAfter(today);
  }
}
