import 'sources.dart';
import '../problem_generation/multiplication.dart';
import '../problem_generation/division.dart';

enum DivMultLevel {
  mk9(
    MultiplicationSplit.k9,
    MultiplicationSource.k9,
    MultiplicationProblem.new,
  ),
  mk8(
    MultiplicationSplit.k8,
    MultiplicationSource.k8,
    MultiplicationProblem.new,
  ),
  mk7(
    MultiplicationSplit.k7,
    MultiplicationSource.k7,
    MultiplicationProblem.new,
  ),
  mk6(
    MultiplicationSplit.k6,
    MultiplicationSource.k6,
    MultiplicationProblem.new,
  ),
  mk5(
    MultiplicationSplit.k5,
    MultiplicationSource.k5,
    MultiplicationProblem.new,
  ),
  mk4(
    MultiplicationSplit.k4,
    MultiplicationSource.k4,
    MultiplicationProblem.new,
  ),
  mk3(
    MultiplicationSplit.k3,
    MultiplicationSource.k3,
    MultiplicationProblem.new,
  ),
  mk2(
    MultiplicationSplit.k2,
    MultiplicationSource.k2,
    MultiplicationProblem.new,
  ),
  mk1(
    MultiplicationSplit.k1,
    MultiplicationSource.k1,
    MultiplicationProblem.new,
  ),
  mdan(
    MultiplicationSplit.dan,
    MultiplicationSource.dan,
    MultiplicationProblem.new,
  ),
  dk8(DivisionSplit.k8, DivisionSource.k8, DivisionProblem.new),
  dk7(DivisionSplit.k7, DivisionSource.k7, DivisionProblem.new),
  dk6(DivisionSplit.k6, DivisionSource.k6, DivisionProblem.new),
  dk5(DivisionSplit.k5, DivisionSource.k5, DivisionProblem.new),
  dk4(DivisionSplit.k4, DivisionSource.k4, DivisionProblem.new),
  dk3(DivisionSplit.k3, DivisionSource.k3, DivisionProblem.new),
  dk2(DivisionSplit.k2, DivisionSource.k2, DivisionProblem.new),
  dk1(DivisionSplit.k1, DivisionSource.k1, DivisionProblem.new),
  ddan(DivisionSplit.dan, DivisionSource.dan, DivisionProblem.new);

  const DivMultLevel(this.divMultSplit, this.divMultSource, this.builder);
  final DivMultSplit divMultSplit;
  final DivMultSource divMultSource;
  final Function builder;
}
