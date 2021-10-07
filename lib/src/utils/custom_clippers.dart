import 'package:flutter/material.dart';

class RRectRevealClipper extends CustomClipper<Path> {
  final Size size;
  final Radius radius;
  final Offset offset;

  RRectRevealClipper({
    required this.size,
    this.radius = Radius.zero,
    this.offset = Offset.zero,
  });

  @override
  Path getClip(Size _) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(
          offset.dx,
          offset.dy,
          offset.dx + size.width,
          offset.dy + size.height,
        ),
        radius,
      ));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
