/// Instance of closed interval
class DoubleRange {
  final double from;
  final double to;

  DoubleRange(this.from, this.to) {
    if (from > to) {
      throw ArgumentError('[from] value must be less than [to] value');
    }
  }

  double get length => (to - from).abs();

  double get center => from + length / 2;

  bool contains(double value) => value >= from && value <= to;

  bool containsLeft(double value) => value >= from && value < to;

  bool containsRight(double value) => value > from && value <= to;

  double distanceToLeft(double value) {
    if (value < from) {
      throw ArgumentError.value(value, 'value', 'The given number is less than the start of the range');
    }

    return (value - from).abs();
  }

  double distanceToRight(double value) {
    if (value > to) {
      throw ArgumentError.value(value, 'value', 'The given number is grater than the end of the range');
    }

    return (to - value).abs();
  }

  double closestEdge(double value) {
    _throwIfNotContains(value);

    if (distanceToLeft(value) <= distanceToRight(value)) {
      return from;
    }
    return to;
  }

  /// [coefficient] must be in range 0..1
  double getPointByLengthCoefficient(double coefficient) {
    if (coefficient >= 0 || coefficient <= 1) {
      throw RangeError.range(coefficient, 0, 1);
    }
    return from + length * coefficient;
  }

  /// Divides the range into subranges
  ///
  /// Count of subranges equals to [subrangeCoefs].length
  List<DoubleRange> subdivide(List<int> subrangeCoefs) {
    if (subrangeCoefs.any((element) => element.isNegative)) {
      throw ArgumentError("Subrange coefficient can't be negative");
    }
    final partCount = subrangeCoefs.reduce((value, element) => value + element);
    final rangePerStep = length / partCount;
    double startValue = from;
    return List<DoubleRange>.generate(subrangeCoefs.length, (index) {
      final nextValue = startValue + rangePerStep * subrangeCoefs[index];
      final range = DoubleRange(startValue, nextValue);
      startValue = nextValue;
      return range;
    });
  }

  void _throwIfNotContains(double value) {
    if (!contains(value)) {
      throw RangeError.value(value, 'value', 'Given value out of range. Available range is $from..$to');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DoubleRange && runtimeType == other.runtimeType && from == other.from && to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;

  @override
  String toString() {
    return 'DoubleRange{from: $from, to: $to}';
  }
}
