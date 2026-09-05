import '../../../../core/errors/messages.dart';
import '../../../../core/seed_works/error.dart';

class SelicValidation {
	ErrorMessages? validatePeriod({
		required DateTime dataInicial,
		required DateTime dataFinal,
	}) {
		if (!dataInicial.isBefore(dataFinal)) {
			return SelicValidationMessage.initialDateAfterFinalDate;
		}

		final maximumDate = DateTime(
			dataInicial.year + 10,
			dataInicial.month,
			dataInicial.day,
		);
		if (dataFinal.isAfter(maximumDate)) {
			return SelicValidationMessage.periodExceedsLimit;
		}

		return null;
	}
}