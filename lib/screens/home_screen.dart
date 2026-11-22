// ============================================================
// home_screen.dart
// Écran d'accueil : recherche, filtres, programmes, voyages de
// l'admin et liste des destinations (tout vient de Firestore).
// Menus : Drawer, TabBar (catégories) et BottomNavigationBar.
// ============================================================
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/destination_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/destination_card.dart';
import '../widgets/program_card.dart';
import '../widgets/state_views.dart';
import '../widgets/travel_background.dart';
import '../widgets/trip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Catégories affichées dans la TabBar (valeurs stockées dans Firestore)
  final categories = ['Tous', 'Plage', 'Culture', 'Nature', 'Ville'];

  // Emoji associé à chaque continent
  final continentEmoji = {
    'Tous': '🌍',
    'Afrique': '🦁',
    'Europe': '🏰',
    'Asie': '🏯',
    'Amérique': '🗽',
    'Océanie': '🦘',
  };

  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // Ouvre un écran réservé aux utilisateurs connectés (sinon : connexion)
  void _openPrivate(String route, {Object? arguments}) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, route, arguments: arguments);
    }
  }

  // Bouton "Se connecter" / "Mon Espace" : redirige selon le rôle
  Future<void> _navigateToSpace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final role = await AuthService().getUserRole(user.uid);
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      role == 'admin' ? '/admin_dashboard' : '/user_dashboard',
    );
  }

  // ------------------------------------------------------------
  // Liste horizontale alimentée par une collection Firestore
  // (gère le chargement, l'erreur et le cas "vide")
  // ------------------------------------------------------------
  Widget _horizontalList({
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required double height,
    required String emptyText,
    required Widget Function(Map<String, dynamic> data) itemBuilder,
  }) {
    return SizedBox(
      height: height,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(context.l10n.errorLoading));
          }
          if (!snapshot.hasData) return const LoadingView();

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return Center(child: Text(emptyText));

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, i) => itemBuilder(docs[i].data()),
          );
        },
      ),
    );
  }

  // En-tête de la liste : titre animé, recherche, filtres, programmes, voyages
  Widget _header(DestinationProvider p) {
    final l = context.l10n;
    const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    final db = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _RotatingTitle(),
        Text(l.destinationsCount(p.total)),
        const SizedBox(height: 14),

        // Barre de recherche
        TextField(
          controller: _search,
          onChanged: p.setQuery,
          decoration: InputDecoration(
            hintText: l.search,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _search.clear();
                      p.setQuery('');
                    },
                  ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
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
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text('${continentEmoji[c]} ${continentLabel(l, c)}'),
                  selected: p.continent == c,
                  onSelected: (_) => p.setContinent(c),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),

        // Programmes (collection "programs")
        Text(l.programs, style: titleStyle),
        const SizedBox(height: 10),
        _horizontalList(
          stream: db.collection('programs').snapshots(),
          height: 160,
          emptyText: l.noProgram,
          itemBuilder: (data) => ProgramCard(program: data),
        ),
        const SizedBox(height: 22),

        // Voyages proposés (collection "trips")
        Text(l.trips, style: titleStyle),
        const SizedBox(height: 10),
        _horizontalList(
          stream: db.collection('trips').orderBy('startDate').snapshots(),
          height: 180,
          emptyText: l.noTrip,
          itemBuilder: (data) => TripCard(trip: data),
        ),
        const SizedBox(height: 24),

        // Message d'erreur (les destinations d'exemple restent affichées)
        if (p.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ErrorView(message: l.errorLoading, onRetry: p.retry),
          ),

        Text('${l.destinations} (${p.filtered.length})', style: titleStyle),
        const SizedBox(height: 14),
      ],
    );
  }

  // Bouton d'authentification (Se connecter / Mon Espace)
  Widget _buildAuthButton() {
    final l = context.l10n;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isConnected = snapshot.hasData;
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: isConnected
              ? OutlinedButton.icon(
                  onPressed: _navigateToSpace,
                  icon: const Icon(Icons.person, size: 18),
                  label: Text(l.monEspace),
                )
              : FilledButton.icon(
                  onPressed: _navigateToSpace,
                  icon: const Icon(Icons.login, size: 18),
                  label: Text(l.login),
                ),
        );
      },
    );
  }

  // Menu latéral (Drawer)
  Widget _buildDrawer() {
    final l = context.l10n;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('PackEasy',
                    style: TextStyle(color: Colors.white, fontSize: 28)),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? l.guest,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l.home),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(l.favorites),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l.history),
            onTap: () {
              Navigator.pop(context);
              _openPrivate('/user_dashboard', arguments: 1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(l.currencyConverter),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/currency');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l.settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),

          // Bouton de changement de thème (clair / sombre)
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => SwitchListTile(
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.teal,
              ),
              title: Text(l.darkTheme),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),

          // Sélecteur de langue
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) => ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.language),
              trailing: DropdownButton<String>(
                value: localeProvider.locale.languageCode,
                onChanged: (code) {
                  if (code != null) localeProvider.setLocale(Locale(code));
                },
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return TravelBackground(
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,

          // AppBar : titre, bouton de thème, bouton de connexion, TabBar des catégories
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('PackEasy',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => IconButton(
                  tooltip: l.changeTheme,
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDarkMode ? Colors.amber : Colors.teal,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                ),
              ),
              _buildAuthButton(),
            ],
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: categories.map((c) => Tab(text: categoryLabel(l, c))).toList(),
              onTap: (i) =>
                  context.read<DestinationProvider>().setCategory(categories[i]),
            ),
          ),

          drawer: _buildDrawer(),

          // Bannière publicitaire + BottomNavigationBar
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BannerAdWidget(),
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                currentIndex: 0,
                onTap: (i) {
                  if (i == 1) _openPrivate('/user_dashboard', arguments: 1);
                  if (i == 2) _openPrivate('/profile');
                },
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.explore), label: l.discover),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.luggage), label: l.myTrips),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.person), label: l.profileTab),
                ],
              ),
            ],
          ),

          // Corps : liste des destinations (chargement / vide / liste)
          body: Consumer<DestinationProvider>(
            builder: (context, p, _) {
              if (p.isLoading) return LoadingView(message: l.loading);

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
                          child: EmptyView(
                            icon: Icons.travel_explore,
                            title: l.noDestination,
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
// Titre qui change toutes les 3 secondes
// ============================================================
class _RotatingTitle extends StatefulWidget {
  const _RotatingTitle();

  @override
  State<_RotatingTitle> createState() => _RotatingTitleState();
}

class _RotatingTitleState extends State<_RotatingTitle> {
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _i = (_i + 1) % 5);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final phrases = [l.phrase1, l.phrase2, l.phrase3, l.phrase4, l.phrase5];

    return SizedBox(
      height: 42,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
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
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
