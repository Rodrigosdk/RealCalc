import '../../../../core/errors/failures.dart';
import '../../../../core/seed_works/result.dart';
import '../entities/value_correction.dart';

abstract class ICalculateValueCorrection {
  Result<Failure, ValueCorrection> calculateValueCorrection();
}
