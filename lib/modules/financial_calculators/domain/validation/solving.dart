import '../../../../core/errors/failures.dart';
import '../../../../core/errors/messages.dart';
import '../../../../core/seed_works/result.dart';

/// Meio centavo: o quanto um valor mostrado na tela pode ter sido arredondado.
const halfCent = 0.005;

/// Raiz de [f] em `[low, high]` por bisseção, com `f(low) < 0 < f(high)` e [f]
/// crescente. Converge sempre, ao contrário do Newton, que diverge com prazos
/// longos.
double solveIncreasing(double Function(double) f, double low, double high) {
  var lo = low;
  var hi = high;
  for (var i = 0; i < 200; i++) {
    final mid = (lo + hi) / 2;
    if (mid == lo || mid == hi) break;
    if (f(mid) < 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return (lo + hi) / 2;
}

/// Prazo a partir de um valor em reais arredondado na tela. Quando o valor
/// fica indistinguível do limite em que o prazo vai ao infinito (a prestação
/// igual aos juros do mês, por exemplo), qualquer prazo a partir de um ponto dá
/// os mesmos centavos e devolve [AmbiguousPeriodsError]. Nos outros casos,
/// devolve o prazo mais próximo, que reproduz o valor mostrado.
Result<Failure, int> periodsFromMoney({
  required double value,
  required double Function(double value) periodsFor,
}) {
  final a = periodsFor(value - halfCent);
  final b = periodsFor(value + halfCent);
  if (!a.isFinite || !b.isFinite) {
    final finite = a.isFinite ? a : b;
    final from = finite.isFinite && finite >= 1 ? finite.ceil() : 1;
    return FailureResult(
      ValidationFailure(message: [AmbiguousPeriodsError(from)]),
    );
  }

  return SuccessResult(periodsFor(value).round());
}
