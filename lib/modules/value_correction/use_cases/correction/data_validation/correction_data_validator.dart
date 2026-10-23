import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/messages.dart';
import '../../../domain/entites/series_point.dart';
import '../../../domain/entites/value_correction.dart';
import '../../../domain/enum/correction_index.dart';
import '../../../domain/enum/series_kind.dart';
import '../../../domain/validation/i_value_correction_validation.dart';
import 'i_correction_data_validator.dart';

class CorrectionDataValidator implements ICorrectionDataValidator {
  final IValueCorrectionValidation _paramsValidation;

  CorrectionDataValidator(this._paramsValidation);

  @override
  Failure? validateParams(ValueCorrection params) =>
      _paramsValidation.validate(params).getErrorOrNull();

  @override
  Failure? validateSeriesAvailability({
    required int index,
    required SeriesKind type,
    required List<SeriesPoint> filteredSeries,
    required List<SeriesPoint> savingsRates,
    required List<SeriesPoint> trPeriods,
    required double? taxaLegalAccumulatedRate,
  }) {
    final hasInvalidSeries =
        ((_isTaxaLegal(index) && taxaLegalAccumulatedRate == null) ||
            (_isSavings(index) && savingsRates.isEmpty) ||
            (!_isTaxaLegal(index) && filteredSeries.isEmpty) ||
            (index == CorrectionIndex.tr.sgsCode && trPeriods.isEmpty)) &&
        type != SeriesKind.dailyRate;

    if (!hasInvalidSeries) return null;
    return ValidationFailure(
      message: [ValueCorrectionValidationMessage.invalidPeriod],
    );
  }

  bool _isTaxaLegal(int index) => index == CorrectionIndex.taxaLegal.sgsCode;

  bool _isSavings(int index) =>
      index == CorrectionIndex.poupancaNova.sgsCode ||
      index == CorrectionIndex.poupancaVelha.sgsCode;
}
