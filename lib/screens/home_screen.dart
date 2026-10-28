import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../services/auth_service.dart'; // <-- AJOUT IMPORTANT
import '../widgets/destination_card.dart';
import '../widgets/destination_image.dart';
import '../widgets/travel_background.dart';
import '../widgets/program_card.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categories = ['Tous', 'Plage', 'Culture', 'Nature', 'Ville'];
  final continentEmoji = {
    'Tous': '🌍',
    'Afrique': '🦁',
    'Europe': '🏰',
    'Asie': '🏯',
    'Amérique': '🗽',
    'Océanie': '🦘',
  };
  final _search = TextEditingController();
  int _navIndex = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE NAVIGATION INTELLIGENTE ---
  Future<void> _navigateToSpace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Pas connecté -> Login
      Navigator.pushNamed(context, '/login');
    } else {
      // Connecté -> On vérifie le rôle
      final role = await AuthService().getUserRole(user.uid);
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushNamed(context, '/user_dashboard');
      }
    }
  }

  Widget _header(DestinationProvider p) {
    const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RotatingTitle(),
        Text('${p.total} destinations • 5 continents'),
        const SizedBox(height: 14),
        // Barre de recherche
        TextField(
          controller: _search,
          onChanged: p.setQuery,
          decoration: InputDecoration(
            hintText: 'Rechercher une ville, un pays...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withAlpha(200),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Filtres continents
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: p.continents.length,
            itemBuilder: (context, i) {
              final c = p.continents[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${continentEmoji[c]} $c'),
                  selected: p.continent == c,
                  onSelected: (_) => p.setContinent(c),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // --- 1. PROGRAMMES & SÉJOURS ---
        const Text('🎒 Programmes & Séjours', style: titleStyle),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('programs').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final programs = snapshot.data!.docs;
              if (programs.isEmpty) return const Center(child: Text("Aucun programme disponible."));
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: programs.length,
                itemBuilder: (context, i) {
                  final data = programs[i].data() as Map<String, dynamic>;
                  return ProgramCard(program: data);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 22),

        // --- 2. VOYAGES À VENIR ---
        const Text('✈️ Voyages à venir', style: titleStyle),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('trips').orderBy('startDate').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final trips = snapshot.data!.docs;
              if (trips.isEmpty) return const Center(child: Text("Aucun voyage planifié."));
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trips.length,
                itemBuilder: (context, i) {
                  final data = trips[i].data() as Map<String, dynamic>;
                  return TripCard(trip: data);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // --- 3. TOUTES LES DESTINATIONS ---
        Text('🌎 Toutes les destinations (${p.filtered.length})', style: titleStyle),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildAuthButton() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isConnected = snapshot.hasData;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: isConnected ? null : const LinearGradient(colors: [Colors.teal, Colors.tealAccent]),
              color: isConnected ? Colors.white.withOpacity(0.7) : null,
              borderRadius: BorderRadius.circular(30),
              border: isConnected ? Border.all(color: Colors.white, width: 1.5) : null,
              boxShadow: [BoxShadow(color: (isConnected ? Colors.black : Colors.teal).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextButton.icon(
              onPressed: _navigateToSpace, // <-- UTILISE LA NOUVELLE MÉTHODE
              icon: Icon(isConnected ? Icons.person : Icons.login, color: isConnected ? Colors.teal : Colors.white, size: 18),
              label: Text(
                isConnected ? "Mon Espace" : "Se connecter",
                style: TextStyle(color: isConnected ? Colors.teal : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TravelBackground(
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('PackEasy ✈️', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [_buildAuthButton()],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: categories.map((c) => Tab(text: c)).toList(),
              onTap: (i) => context.read<DestinationProvider>().setCategory(categories[i]),
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: const [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal),
                  child: Text('PackEasy', style: TextStyle(color: Colors.white, fontSize: 28)),
                ),
                ListTile(leading: Icon(Icons.home), title: Text('Accueil')),
                ListTile(leading: Icon(Icons.favorite), title: Text('Favoris')),
                ListTile(leading: Icon(Icons.history), title: Text('Historique')),
                ListTile(leading: Icon(Icons.settings), title: Text('Paramètres')),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _navIndex,
            onTap: (i) {
              setState(() => _navIndex = i);
              if (i != 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Écran bientôt disponible')),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Découvrir'),
              BottomNavigationBarItem(icon: Icon(Icons.luggage), label: 'Voyages'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
          body: Consumer<DestinationProvider>(
            builder: (context, p, _) {
              if (p.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Préparation de votre voyage...'),
                    ],
                  ),
                );
              }
              
              final list = p.filtered;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.isEmpty ? 2 : list.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) return _header(p);
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Icon(Icons.travel_explore, size: 70),
                              SizedBox(height: 8),
                              Text('Aucune destination trouvée'),
                            ],
                          ),
                        );
                      }
                      return DestinationCard(
                        key: ValueKey(list[i - 1].id),
                        destination: list[i - 1],
                        index: i - 1,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Titre dont le texte change toutes les 3 secondes
class _RotatingTitle extends StatefulWidget {
  const _RotatingTitle();

  @override
  State<_RotatingTitle> createState() => _RotatingTitleState();
}

class _RotatingTitleState extends State<_RotatingTitle> {
  final phrases = [
    'Où voulez-vous aller ?',
    'Plages de rêve 🏝️',
    'Villes inoubliables 🌆',
    'Aventures nature 🏔️',
    'Culture et histoire 🏛️',
  ];
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _i = (_i + 1) % phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: Text(
            phrases[_i],
            key: ValueKey(_i),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}