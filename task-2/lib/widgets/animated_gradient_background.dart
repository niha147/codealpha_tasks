import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class AnimatedGradientBackground extends ConsumerWidget {
  final Widget child;

  const AnimatedGradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return TweenAnimationBuilder<List<Color>>(
      tween: ColorListTween(begin: colors, end: colors),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      child: child, // Pass the child to the TweenAnimationBuilder
      builder: (context, currentColors, cachedChild) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: currentColors,
            ),
          ),
          child: Stack(
            children: [
              _buildParticles(),
              cachedChild!, // Use the cached child
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    // A simple representation of floating particles using positioned blurred circles
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.02),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.02),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ColorListTween extends Tween<List<Color>> {
  ColorListTween({List<Color>? begin, List<Color>? end}) : super(begin: begin, end: end);

  @override
  List<Color> lerp(double t) {
    if (begin == null || end == null) return end ?? begin ?? [];
    final int maxLength = max(begin!.length, end!.length);
    return List.generate(maxLength, (i) {
      final beginColor = i < begin!.length ? begin![i] : begin!.last;
      final endColor = i < end!.length ? end![i] : end!.last;
      return Color.lerp(beginColor, endColor, t)!;
    });
  }
}
