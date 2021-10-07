import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CustomizableTab extends Equatable {
  const CustomizableTab({
    required this.label,
    this.flex = 1,
    this.color,
    this.selectedTextColor,
    this.backgroundColor,
    this.textColor,
    this.splashColor,
    this.splashHighlightColor,
  }) : assert(flex > 0);

  final String label;
  final int flex;
  // All provided properties will replace the colors specified in [RoundedTabBar]
  final Color? color;
  final Color? selectedTextColor;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  List<Object?> get props => [
        label,
        flex,
        color,
        selectedTextColor,
        backgroundColor,
        textColor,
        splashColor,
        splashHighlightColor,
      ];
}
