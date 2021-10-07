import 'package:flutter/material.dart';

import 'range.dart';

class AnimationConverter {
  AnimationConverter({
    required this.animation,
    this.minAnimationValue = 0,
    this.maxAnimationValue = 1,
    required this.stops,
  })  : assert(minAnimationValue <= maxAnimationValue),
        assert(stops.isNotEmpty),
        assert(stops.keys
            .every((e) => e > minAnimationValue && e < maxAnimationValue)),
        assert(stops.values
            .every((e) => e > minAnimationValue && e < maxAnimationValue));

  final Animation<double> animation;
  final double minAnimationValue;
  final double maxAnimationValue;
  final Map<double, double> stops;

  late final List<DoubleRange> _stopsRanges =
      _generateRanges(stops.values.toList());
  late final List<DoubleRange> _sourceRanges =
      _generateRanges(stops.keys.toList());

  late final List<double> _speedCoefs = List.generate(_stopsRanges.length,
      (index) => _stopsRanges[index].length / _sourceRanges[index].length);

  List<DoubleRange> _generateRanges(List<double> stops) {
    List<DoubleRange> ranges = [DoubleRange(minAnimationValue, stops.first)];
    for (int i = 0; i < stops.length - 1; i++) {
      ranges = [...ranges, DoubleRange(stops[i], stops[i + 1])];
    }
    ranges = [...ranges, DoubleRange(stops.last, maxAnimationValue)];
    return ranges;
  }

  double call(double value) => convert(value);

  double convert(double value) {
    final sourceRangeIndex = _findInRanges(value, _sourceRanges);
    if (sourceRangeIndex == null) {
      throw RangeError(
          'Animation value out of range. Available range is $minAnimationValue..$maxAnimationValue');
    }
    final stopRange = _stopsRanges[sourceRangeIndex];
    return (value - _sourceRanges[sourceRangeIndex].from) *
            _speedCoefs[sourceRangeIndex] +
        stopRange.from;
  }

  double reverse(double value) {
    final stopRangeIndex = _findInRanges(value, _stopsRanges);
    if (stopRangeIndex == null) {
      throw RangeError(
          'Animation value out of range. Available range is $minAnimationValue..$maxAnimationValue');
    }
    final sourceRange = _sourceRanges[stopRangeIndex];
    return (value - _stopsRanges[stopRangeIndex].from) *
            (1 - _speedCoefs[stopRangeIndex]) +
        sourceRange.from;
  }

  int? _findInRanges(double value, List<DoubleRange> ranges) {
    if (value < ranges.first.from) {
      return 0;
    }
    if (value > ranges.last.to) {
      return ranges.length - 2;
    }
    for (int i = 0; i < ranges.length; i++) {
      if (ranges[i].contains(value)) {
        return i;
      }
    }
  }

  @override
  String toString() {
    return 'AnimationConverter{animation: $animation, minAnimationValue: $minAnimationValue, maxAnimationValue: $maxAnimationValue, stops: $stops}';
  }
}
