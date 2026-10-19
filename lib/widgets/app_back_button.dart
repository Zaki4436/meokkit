import 'package:flutter/material.dart';

/// Reusable Back Button with smooth transition matching the setting_history page design.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? shadowColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFFBD3546);
    final effectiveShadow = shadowColor ?? effectiveColor.withOpacity(0.16);

    return Positioned(
      top: 8,
      left: 12,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) => Opacity(
          opacity: val,
          child: Transform.scale(
            scale: 0.85 + (0.15 * val),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.white.withOpacity(0.88),
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: effectiveShadow,
          child: IconButton(
            tooltip: 'Back',
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: effectiveColor,
              size: 19,
            ),
            onPressed: onPressed ?? () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}

