import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlipCardWidget extends StatelessWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;

  const FlipCardWidget({
    super.key,
    required this.front,
    required this.back,
    required this.isFlipped,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        bool isBack = value >= 90;
        double rotation = value * math.pi / 180;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(rotation),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}
