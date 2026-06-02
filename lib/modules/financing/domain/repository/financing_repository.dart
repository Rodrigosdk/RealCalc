import 'package:real_calc/core/seed_works/result.dart';

import '../../../../core/errors/failures.dart';
import '../entities/financing.dart';

abstract class FinancingRepository{
  Future<Result<Failure, String>> save(Financing financing);
} 