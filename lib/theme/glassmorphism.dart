import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    Key? key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius,
            border: border ?? Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
