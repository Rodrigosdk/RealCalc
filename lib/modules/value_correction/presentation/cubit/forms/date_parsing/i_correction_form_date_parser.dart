import '../../../../domain/enum/date_granularity.dart';

abstract interface class ICorrectionFormDateParser {
  DateTime? parse(String value, DateGranularity granularity);

  bool isFutureDate(String value, DateGranularity granularity);
}
