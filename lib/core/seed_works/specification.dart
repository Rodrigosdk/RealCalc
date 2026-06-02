abstract class Specification<T, E> {
  List<E> validate(T candidate);

  // Operador AND
  Specification<T, E> and(Specification<T, E> other) {
    return AndSpecification<T, E>(this, other);
  }

  // Operador OR
  Specification<T, E> or(Specification<T, E> other) {
    return OrSpecification<T, E>(this, other);
  }

  // Operador NOT (Inverte o resultado com base em um erro padrão)
  Specification<T, E> not(E errorIfTrue) {
    return NotSpecification<T, E>(this, errorIfTrue);
  }
}

// Implementação do OR: Se uma passar (lista vazia), o objeto é válido
class OrSpecification<T, E> extends Specification<T, E> {
  final Specification<T, E> _left;
  final Specification<T, E> _right;

  OrSpecification(this._left, this._right);

  @override
  List<E> validate(T candidate) {
    final leftErrors = _left.validate(candidate);
    // Se o lado esquerdo passou (sem erros), ignora o direito
    if (leftErrors.isEmpty) return [];
    
    final rightErrors = _right.validate(candidate);
    if (rightErrors.isEmpty) return [];

    // Se ambos falharem, retorna a combinação de erros
    return [...leftErrors, ...rightErrors];
  }
}

// Implementação do NOT
class NotSpecification<T, E> extends Specification<T, E> {
  final Specification<T, E> _specification;
  final E _errorIfTrue;

  NotSpecification(this._specification, this._errorIfTrue);

  @override
  List<E> validate(T candidate) {
    final errors = _specification.validate(candidate);
    // Se a especificação original NÃO tem erros (é verdadeira), agora ela falha
    if (errors.isEmpty) {
      return [_errorIfTrue];
    }
    // Se ela tinha erros (era falsa), agora ela passa
    return [];
  }
}

// Classe composta existente
class CompositeSpecification<T, E> implements Specification<T, E> {
  final List<Specification<T, E>> specifications;
  CompositeSpecification(this.specifications);

  @override
  List<E> validate(T candidate) {
    return specifications.expand((spec) => spec.validate(candidate)).toList();
  }

  @override
  Specification<T, E> and(Specification<T, E> other) => AndSpecification(this, other);

  @override
  Specification<T, E> or(Specification<T, E> other) => OrSpecification(this, other);

  @override
  Specification<T, E> not(E errorIfTrue) => NotSpecification(this, errorIfTrue);
}

// Implementação do AND: Ambas as especificações precisam passar
class AndSpecification<T, E> extends Specification<T, E> {
  final Specification<T, E> _left;
  final Specification<T, E> _right;

  AndSpecification(this._left, this._right);

  @override
  List<E> validate(T candidate) {
    final leftErrors = _left.validate(candidate);
    final rightErrors = _right.validate(candidate);
    return [...leftErrors, ...rightErrors];
  }
}