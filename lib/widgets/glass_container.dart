import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On Web (especially HTML renderer), BackdropFilter is very expensive.
      // We skip the blur and just use a semi-transparent colored container.
      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity + 0.1), // Slightly more opaque since no blur
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          border: border ?? Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: boxShadow,
          gradient: gradient,
        ),
        child: child, // No ClipRRect needed if we don't blur, simple radius is fine on Container
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: border ?? Border.all(color: Colors.white.withOpacity(0.2)),
              gradient: gradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
