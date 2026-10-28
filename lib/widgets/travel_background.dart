import 'dart:math';
import 'package:flutter/material.dart';

class TravelBackground extends StatefulWidget {
  final Widget child;
  const TravelBackground({super.key, required this.child});

  @override
  State<TravelBackground> createState() => _TravelBackgroundState();
}

class _TravelBackgroundState extends State<TravelBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<List<double>> _stars; // x, y, phase, taille

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
    final rnd = Random(7);
    _stars = List.generate(
      35,
      (_) => [
        rnd.nextDouble() * 2 - 1,
        rnd.nextDouble() * 2 - 1,
        rnd.nextDouble() * 2 * pi,
        3 + rnd.nextDouble() * 5,
      ],
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Alignment _planePath(double q) =>
      Alignment(-1.3 + 2.6 * q, -0.55 - 0.2 * sin(q * pi));

  Widget _cloud(double t, double offset, double y, double size, Color color, double speed) {
    final q = (t * speed + offset) % 1;
    return Align(
      alignment: Alignment(-1.4 + 2.8 * q, y),
      child: Icon(Icons.cloud, size: size, color: color),
    );
  }

  Widget _sky(bool dark, double t) {
    // Le dégradé change doucement de couleur
    final wave = (sin(t * 2 * pi * 3) + 1) / 2;
    final top = dark
        ? Color.lerp(const Color(0xFF0D1B3E), const Color(0xFF1A237E), wave)!
        : Color.lerp(const Color(0xFF81D4FA), const Color(0xFFB39DDB), wave)!;
    final bottom = dark
        ? Color.lerp(const Color(0xFF311B92), const Color(0xFF4A148C), wave)!
        : Color.lerp(const Color(0xFFFFF3E0), const Color(0xFFFFCCBC), wave)!;
    final cloudColor = dark ? Colors.white10 : Colors.white70;
    final p = (t * 3) % 1; // progression de l'avion

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
          ),
        ),

        // Étoiles scintillantes (thème sombre)
        if (dark)
          for (final s in _stars)
            Align(
              alignment: Alignment(s[0], s[1]),
              child: Opacity(
                opacity: 0.3 + 0.7 * (sin(t * 2 * pi * 20 + s[2]) + 1) / 2,
                child: Icon(Icons.star, size: s[3] * 2, color: Colors.white),
              ),
            ),

        // Globe qui tourne lentement
        Positioned(
          right: -90,
          bottom: -90,
          child: Opacity(
            opacity: 0.12,
            child: Transform.rotate(
              angle: t * 2 * pi * 2,
              child: const Icon(Icons.public, size: 340, color: Colors.white),
            ),
          ),
        ),

        // Nuages
        _cloud(t, 0.0, -0.8, 70, cloudColor, 2),
        _cloud(t, 0.4, -0.2, 50, cloudColor, 3),
        _cloud(t, 0.7, 0.4, 80, cloudColor, 2),
        _cloud(t, 0.2, 0.85, 55, cloudColor, 4),

        // Traînée de l'avion
        for (int i = 1; i <= 6; i++)
          Align(
            alignment: _planePath(max(p - i * 0.012, 0)),
            child: Opacity(
              opacity: 0.6 - i * 0.09,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),

        // Avion qui traverse l'écran
        Align(
          alignment: _planePath(p),
          child: Transform.rotate(
            angle: pi / 2,
            child: const Icon(Icons.flight,
                size: 34,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 6)]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Seul le fond est redessiné à chaque image, pas le contenu
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => _sky(dark, _c.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}