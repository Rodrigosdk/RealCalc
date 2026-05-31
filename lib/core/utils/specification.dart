abstract class Specification<T> {
  List<String> validate(T candidate);
}

class CompositeSpecification<T> implements Specification<T> {
  final List<Specification<T>> specifications;

  CompositeSpecification(this.specifications);

  @override
  List<String> validate(T candidate) {
    return specifications
        .expand((spec) => spec.validate(candidate))
        .toList();
  }
}
