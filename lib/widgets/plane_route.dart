import 'dart:math';
import 'package:flutter/material.dart';

class PlaneRoute extends PageRouteBuilder {
  PlaneRoute({required Widget page, RouteSettings? settings})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 1500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondary) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final size = MediaQuery.of(context).size;

            // La page n'apparaît que dans la 2e moitié du vol
            final reveal = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                FadeTransition(
                  opacity: reveal,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.08), end: Offset.zero)
                        .animate(reveal),
                    child: child,
                  ),
                ),
                // L'avion n'est affiché qu'à l'aller
                if (animation.status == AnimationStatus.forward)
                  AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) =>
                        IgnorePointer(child: _flight(animation.value, size)),
                  ),
              ],
            );
          },
        );
}

Widget _flight(double value, Size size) {
  final p = (value / 0.8).clamp(0.0, 1.0);

  // Trajectoire en arc, du bas-gauche vers le haut-droit
  Offset pos(double q) => Offset(
        -60 + (size.width + 120) * q,
        size.height * 0.8 - size.height * 0.6 * q - sin(q * pi) * size.height * 0.1,
      );

  final now = pos(p);
  final next = pos(p + 0.01);
  // Le nez de l'avion suit la direction du vol
  final angle = atan2(next.dy - now.dy, next.dx - now.dx) + pi / 2;

  return Stack(
    fit: StackFit.expand,
    children: [
      // Le ciel se teinte pendant le vol
      Opacity(
        opacity: sin(value * pi) * 0.3,
        child: const ColoredBox(color: Colors.lightBlue),
      ),
      // Traînée de points
      for (int i = 1; i <= 10; i++)
        Positioned(
          left: pos(max(p - i * 0.025, 0)).dx - (14 - i) / 2,
          top: pos(max(p - i * 0.025, 0)).dy - (14 - i) / 2,
          child: Opacity(
            opacity: 0.8 * (1 - i / 11),
            child: Container(
              width: 14.0 - i,
              height: 14.0 - i,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      // L'avion
      Positioned(
        left: now.dx - 30,
        top: now.dy - 30,
        child: Transform.rotate(
          angle: angle,
          child: const Icon(
            Icons.flight,
            size: 60,
            color: Colors.orange,
            shadows: [Shadow(color: Colors.black38, blurRadius: 12)],
          ),
        ),
      ),
    ],
  );
}