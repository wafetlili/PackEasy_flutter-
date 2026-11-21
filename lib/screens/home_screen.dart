// ============================================================
// home_screen.dart
// Écran d'accueil : recherche, filtres, programmes, voyages
// et liste des destinations.
// ============================================================
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../widgets/destination_card.dart';
import '../widgets/travel_background.dart';
import '../widgets/program_card.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Catégories affichées dans la TabBar
  final categories = ['Tous', 'Plage', 'Culture', 'Nature', 'Ville'];

  // Emoji associé à chaque continent pour les filtres
  final continentEmoji = {
    'Tous': '🌍',
    'Afrique': '🦁',
    'Europe': '🏰',
    'Asie': '🏯',
    'Amérique': '🗽',
    'Océanie': '🦘',
  };

  // Contrôleur de la barre de recherche
  final _search = TextEditingController();

  // Index de l'onglet actif dans la BottomNavigationBar
  int _navIndex = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // Navigation intelligente : redirige vers login, dashboard
  // utilisateur ou dashboard admin selon l'état de connexion.
  // ------------------------------------------------------------
  Future<void> _navigateToSpace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final role = await AuthService().getUserRole(user.uid);
      if (!mounted) return;
      if (role == 'admin') {
        Navigator.pushNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushNamed(context, '/user_dashboard');
      }
    }
  }

  // ------------------------------------------------------------
  // En-tête de la page : titre animé, recherche, filtres,
  // programmes et voyages à venir.
  // ------------------------------------------------------------
  Widget _header(DestinationProvider p) {
    final l10n = AppLocalizations.of(context)!;
    const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RotatingTitle(),
        Text('${p.total} destinations - 5 continents'),
        const SizedBox(height: 14),

        // Barre de recherche avec texte traduit
        TextField(
          controller: _search,
          onChanged: p.setQuery,
          decoration: InputDecoration(
            hintText: l10n.search,
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

        // Filtres par continent
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

        // Section 1 : programmes
        Text(l10n.programs, style: titleStyle),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('programs')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final programs = snapshot.data!.docs;

              if (programs.isEmpty) {
                return Center(child: Text(l10n.noProgram));
              }

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

        // Section 2 : voyages
        Text(l10n.trips, style: titleStyle),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .orderBy('startDate')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final trips = snapshot.data!.docs;

              if (trips.isEmpty) {
                return Center(child: Text(l10n.noTrip));
              }

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

        // Section 3 : toutes les destinations
        Text(
          '${l10n.destinations} (${p.filtered.length})',
          style: titleStyle,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ------------------------------------------------------------
  // Bouton d'authentification (Se connecter / Mon Espace)
  // ------------------------------------------------------------
  Widget _buildAuthButton() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isConnected = snapshot.hasData;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: isConnected
                  ? null
                  : const LinearGradient(
                      colors: [Colors.teal, Colors.tealAccent],
                    ),
              color: isConnected ? Colors.white.withOpacity(0.7) : null,
              borderRadius: BorderRadius.circular(30),
              border: isConnected
                  ? Border.all(color: Colors.white, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? Colors.black : Colors.teal)
                      .withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: _navigateToSpace,
              icon: Icon(
                isConnected ? Icons.person : Icons.login,
                color: isConnected ? Colors.teal : Colors.white,
                size: 18,
              ),
              label: Text(
                isConnected ? l10n.monEspace : l10n.login,
                style: TextStyle(
                  color: isConnected ? Colors.teal : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Construction de la page principale
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TravelBackground(
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,

          // AppBar : titre, bouton de thème, bouton de connexion, TabBar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'PackEasy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              // Bouton de changement de thème
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    tooltip: 'Changer de theme',
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: themeProvider.isDarkMode
                          ? Colors.amber
                          : Colors.teal,
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              // Bouton de connexion / Mon Espace
              _buildAuthButton(),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: categories.map((c) => Tab(text: c)).toList(),
              onTap: (i) => context
                  .read<DestinationProvider>()
                  .setCategory(categories[i]),
            ),
          ),

          // Drawer : menu latéral avec bouton de thème et sélecteur de langue
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal),
                  child: Text(
                    'PackEasy',
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(l10n.home),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(l10n.favorites),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(l10n.history),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                ),

                // Bouton de changement de thème
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return SwitchListTile(
                      secondary: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: themeProvider.isDarkMode
                            ? Colors.amber
                            : Colors.teal,
                      ),
                      title: Text(l10n.darkTheme),
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    );
                  },
                ),

                // Sélecteur de langue
                Consumer<LocaleProvider>(
                  builder: (context, localeProvider, _) {
                    return ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                      trailing: DropdownButton<String>(
                        value: localeProvider.locale.languageCode,
                        onChanged: (code) {
                          if (code != null) {
                            localeProvider.setLocale(Locale(code));
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'fr', child: Text('Français')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // BottomNavigationBar
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _navIndex,
            onTap: (i) {
              setState(() => _navIndex = i);
              if (i != 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ecran bientot disponible')),
                );
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore),
                label: l10n.discover,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.luggage),
                label: l10n.trips,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: l10n.profileTab,
              ),
            ],
          ),

          // Corps : liste des destinations
          body: Consumer<DestinationProvider>(
            builder: (context, p, _) {
              if (p.isLoading) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(l10n.loading),
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              const Icon(Icons.travel_explore, size: 70),
                              const SizedBox(height: 8),
                              Text(l10n.noDestination),
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

// ============================================================
// Widget : titre rotatif qui change toutes les 3 secondes
// ============================================================
class _RotatingTitle extends StatefulWidget {
  const _RotatingTitle();

  @override
  State<_RotatingTitle> createState() => _RotatingTitleState();
}

class _RotatingTitleState extends State<_RotatingTitle> {
  final phrases = [
    'Ou voulez-vous aller ?',
    'Plages de reve',
    'Villes inoubliables',
    'Aventures nature',
    'Culture et histoire',
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
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            phrases[_i],
            key: ValueKey(_i),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}