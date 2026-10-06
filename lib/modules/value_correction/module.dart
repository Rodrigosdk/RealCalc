import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:real_calc/core/module.dart';

import '../../core/routes/app_routes.dart';
import 'domain/entites/value_correction.dart';
import 'domain/enum/correction_index.dart';
import 'domain/repositories/i_correction_series_repository.dart';
import 'domain/services/value_correction_sharer.dart';
import 'domain/validation/i_value_correction_validation.dart';
import 'domain/validation/value_correction_validation.dart';
import 'infrastructure/repositories/sgs_repository.dart';
import 'infrastructure/services/share_plus_value_correction_sharer.dart';
import 'presentation/cubit/value_correction/value_correction_cubit.dart';
import 'presentation/cubit/value_correction/request_parsing/i_value_correction_request_parser.dart';
import 'presentation/cubit/value_correction/request_parsing/value_correction_request_parser.dart';
import 'presentation/cubit/value_correction/request_validation/i_value_correction_request_validator.dart';
import 'presentation/cubit/value_correction/request_validation/value_correction_request_validator.dart';
import 'presentation/cubit/forms/date_formatting/correction_form_input_formatter.dart';
import 'presentation/cubit/forms/date_formatting/i_correction_form_input_formatter.dart';
import 'presentation/cubit/forms/date_parsing/correction_form_date_parser.dart';
import 'presentation/cubit/forms/date_parsing/i_correction_form_date_parser.dart';
import 'presentation/cubit/forms/validation/correction_form_validator.dart';
import 'presentation/cubit/forms/validation/i_correction_form_validator.dart';
import 'presentation/cubit/forms/value_correction_form_cubit.dart';
import 'presentation/pages/value_correction_page.dart';
import 'presentation/pages/value_correction_result_page.dart';
import 'use_cases/calculate_value_correction.dart';
import 'use_cases/correction/data_preparation/correction_data_preparer.dart';
import 'use_cases/correction/data_preparation/i_correction_data_preparer.dart';
import 'use_cases/correction/data_validation/correction_data_validator.dart';
import 'use_cases/correction/data_validation/i_correction_data_validator.dart';
import 'use_cases/correction/rate_calculation/correction_rate_calculator.dart';
import 'use_cases/correction/rate_calculation/i_correction_rate_calculator.dart';
import 'use_cases/correction/series_filtering/correction_period_series_filter.dart';
import 'use_cases/correction/series_filtering/i_correction_period_series_filter.dart';
import 'use_cases/correction/series_selection/correction_index_series_selector.dart';
import 'use_cases/correction/series_selection/i_correction_index_series_selector.dart';
import 'use_cases/i_calculate_value_correction.dart';

class ValueCorrectionModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  void binds(Injector i) {
    i.addLazySingleton<IValueCorrectionValidation>(
      ValueCorrectionValidation.new,
    );
    i.addLazySingleton<ICorrectionRateCalculator>(CorrectionRateCalculator.new);
    i.addLazySingleton<ICorrectionDataValidator>(CorrectionDataValidator.new);
    i.addLazySingleton<ICorrectionPeriodSeriesFilter>(
      CorrectionPeriodSeriesFilter.new,
    );
    i.addLazySingleton<ICorrectionIndexSeriesSelector>(
      CorrectionIndexSeriesSelector.new,
    );
    i.addLazySingleton<ICorrectionFormDateParser>(CorrectionFormDateParser.new);
    i.addLazySingleton<ICorrectionFormInputFormatter>(
      CorrectionFormInputFormatter.new,
    );
    i.addLazySingleton<ICorrectionFormValidator>(CorrectionFormValidator.new);
    i.addLazySingleton<IValueCorrectionRequestParser>(
      ValueCorrectionRequestParser.new,
    );
    i.addLazySingleton<IValueCorrectionRequestValidator>(
      ValueCorrectionRequestValidator.new,
    );
    i.addLazySingleton<ICorrectionDataPreparer>(CorrectionDataPreparer.new);
    i.addLazySingleton<ICorrectionSeriesRepository>(SgsRepository.new);
    i.addLazySingleton<ICalculateValueCorrection>(CalculateValueCorrection.new);
    i.addLazySingleton<ValueCorrectionSharer>(
      SharePlusValueCorrectionSharer.new,
    );
    i.addLazySingleton<ValueCorrectionFormCubit>(ValueCorrectionFormCubit.new);
    i.addLazySingleton<ValueCorrectionCubit>(ValueCorrectionCubit.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      AppRoutes.base,
      child: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                Modular.get<ValueCorrectionFormCubit>()
                  ..setIndex(CorrectionIndex.ipca),
          ),
          BlocProvider(create: (_) => Modular.get<ValueCorrectionCubit>()),
        ],
        child: const ValueCorrectionPage(),
      ),
    );
    r.child(
      '/${AppRoutes.correctionResultSegment}',
      child: (_) {
        final result = Modular.args.data as ValueCorrection;
        return ValueCorrectionResultPage(result: result);
      },
    );
  }
}
