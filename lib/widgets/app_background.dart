import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/background/background.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        child,
      ],
    );
  }
}