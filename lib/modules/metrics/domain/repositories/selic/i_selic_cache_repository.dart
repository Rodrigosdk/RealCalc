import '../../entites/metric.dart';
import '../../enum/selic_period.dart';

abstract class ISelicCacheRepository {
  Future<Metric?> read(SelicPeriod period);
  Future<void> save(SelicPeriod period, Metric metric);
}
