import 'dart:math';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; // animation d'entrée (une seule fois)
  late final AnimationController _loop; // animation en boucle (avion, nuages...)

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..forward();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  // Une portion de l'animation d'entrée (début et fin entre 0 et 1)
  Animation<double> _step(double begin, double end) => CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: Curves.easeOut),
      );

  // Fondu + glissement vers le haut
  Widget _appear(Animation<double> anim, Widget child) {
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  // Nuage qui traverse l'écran de gauche à droite
  Widget _cloud(double phase, double y, double size) {
    final t = (_loop.value + phase) % 1;
    return Align(
      alignment: Alignment(-1.4 + 2.8 * t, y),
      child: Icon(Icons.cloud, size: size, color: Colors.white),
    );
  }

  // Icône qui flotte de haut en bas
  Widget _floating(IconData icon, Color color, Alignment pos, double phase) {
    final dy = sin(_loop.value * 2 * pi * 6 + phase) * 8;
    return Align(
      alignment: pos,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Opacity(
          opacity: _intro.value,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _illustration() {
    // Effet de rebond à l'apparition du globe
    final pop = Curves.elasticOut.transform((_intro.value / 0.5).clamp(0.0, 1.0));

    return Stack(
      children: [
        _cloud(0.0, -0.9, 60),
        _cloud(0.5, -0.4, 40),
        _cloud(0.25, 0.9, 50),

        // Globe + orbite + avion
        Center(
          child: FittedBox(
            child: Transform.scale(
              scale: pop,
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cercle de l'orbite
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    // Globe
                    Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF42A5F5), Color(0xFF26C6DA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 10)),
                        ],
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.public, size: 150, color: Colors.white54),
                          Positioned(
                            bottom: 30,
                            child: Icon(Icons.landscape,
                                size: 80, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Avion qui tourne autour du globe
                    Transform.rotate(
                      angle: _loop.value * 2 * pi,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Transform.rotate(
                            angle: pi / 2, // le nez de l'avion suit la trajectoire
                            child: const Icon(Icons.flight,
                                size: 44, color: Colors.orange),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Icônes flottantes
        _floating(Icons.location_on, Colors.red, const Alignment(-0.85, -0.5), 0),
        _floating(Icons.luggage, Colors.brown, const Alignment(0.85, -0.3), 1.5),
        _floating(Icons.beach_access, Colors.orange, const Alignment(-0.8, 0.6), 3),
        _floating(Icons.camera_alt, Colors.indigo, const Alignment(0.8, 0.7), 4.5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _step(0.45, 0.8);
    final subtitle = _step(0.55, 0.9);
    final button = _step(0.7, 1.0);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Partie haute : illustration animée
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_intro, _loop]),
                  builder: (context, _) => _illustration(),
                ),
              ),

              // Partie basse : textes + bouton
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _appear(
                        title,
                        const Text(
                          'Votre guide de voyage ultime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _appear(
                        subtitle,
                        const Text(
                          'Trouvez la destination adaptée à votre budget, '
                          'planifiez vos visites et préparez vos bagages.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _appear(
                        button,
                        // Bouton qui pulse doucement
                        AnimatedBuilder(
                          animation: _loop,
                          builder: (context, child) => Transform.scale(
                            scale: 1 + 0.04 * sin(_loop.value * 2 * pi * 12),
                            child: child,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                              // MODIFICATION ICI : Redirection vers '/login'
                              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                                  child: const Text('Commencer', style: TextStyle(fontSize: 18)),


                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}