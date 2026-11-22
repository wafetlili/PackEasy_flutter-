// ============================================================
// user_dashboard.dart
// Espace voyageur : Drawer + BottomNavigationBar + 4 onglets.
// L'onglet "Voyages" possède son propre Navigator (navigation
// imbriquée) : liste des voyages -> détails d'un voyage.
// Un index d'onglet peut être passé en argument de la route.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../services/auth_service.dart';
import '../utils/l10n_ext.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/state_views.dart';
import '../widgets/travel_background.dart';
import 'tabs/budget_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/packing_tab.dart';
import 'tabs/trips_tab.dart';
import 'trip_details_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _index = 0;
  bool _argumentsRead = false;

  // Navigator imbriqué de l'onglet "Voyages"
  final _tripsNavKey = GlobalKey<NavigatorState>();
  bool _tripsCanPop = false; // vrai quand l'écran "détails d'un voyage" est ouvert

  // Lit l'onglet demandé dans les arguments de la route (ex : Navigator.pushNamed(..., arguments: 1))
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argumentsRead) return;
    _argumentsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && args >= 0 && args < 4) _index = args;
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  // Appelée par l'observateur quand le navigator imbriqué change d'écran
  void _onTripsNavChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canPop = _tripsNavKey.currentState?.canPop() ?? false;
      if (mounted && canPop != _tripsCanPop) setState(() => _tripsCanPop = canPop);
    });
  }

  // Navigator imbriqué : '/' = liste des voyages, '/trip' = détails (argument : le voyage)
  Widget _buildTripsNavigator() {
    return Navigator(
      key: _tripsNavKey,
      initialRoute: '/',
      observers: [_TripsNavObserver(_onTripsNavChanged)],
      onGenerateRoute: (settings) {
        if (settings.name == '/trip') {
          final trip = settings.arguments as Trip;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => TripDetailsScreen(trip: trip),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const TripsTab(),
        );
      },
    );
  }

  // Bouton d'action flottant selon l'onglet
  Widget? _fab() {
    final l = context.l10n;
    switch (_index) {
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => showAddTripSheet(context),
          icon: const Icon(Icons.add_location_alt),
          label: Text(l.newTrip),
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () => showAddExpenseSheet(context),
          icon: const Icon(Icons.add),
          label: Text(l.expense),
        );
      case 3:
        return FloatingActionButton.extended(
          onPressed: () => showAddItemDialog(context),
          icon: const Icon(Icons.add),
          label: Text(l.item),
        );
      default:
        return null;
    }
  }

  void _go(int i) {
    setState(() => _index = i);
    Navigator.pop(context); // ferme le Drawer
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? l.user;
    final titles = [l.mySpace, l.myTrips, l.budget, l.myBag];

    // Vue "non connecté" (ex : arrivée depuis une notification)
    final loggedIn = context.select<TripProvider, bool>((p) => p.isLoggedIn);
    if (user == null && !loggedIn) {
      return TravelBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.loginRequired),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(l.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final trips = context.watch<TripProvider>();

    final pages = [
      OverviewTab(onGo: (i) => setState(() => _index = i)),
      _buildTripsNavigator(),
      const BudgetTab(),
      const PackingTab(),
    ];

    // Le bouton "retour" du téléphone remonte d'abord dans le navigator imbriqué
    return PopScope(
      canPop: !(_index == 1 && _tripsCanPop),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _tripsNavKey.currentState?.maybePop();
      },
      child: TravelBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(titles[_index],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                tooltip: l.exploreDestinations,
                icon: const Icon(Icons.explore),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              IconButton(
                tooltip: l.logout,
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.teal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(email[0].toUpperCase(),
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(height: 8),
                      Text(email,
                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: Text(l.monEspace),
                    onTap: () => _go(0)),
                ListTile(
                    leading: const Icon(Icons.flight_takeoff),
                    title: Text(l.myTrips),
                    onTap: () => _go(1)),
                ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(l.budget),
                    onTap: () => _go(2)),
                ListTile(
                    leading: const Icon(Icons.checklist),
                    title: Text(l.myBag),
                    onTap: () => _go(3)),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.public),
                  title: Text(l.exploreDestinations),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/home');
                  },
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
                  leading: const Icon(Icons.currency_exchange),
                  title: Text(l.currencyConverter),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/currency');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(l.profile),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
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
                ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l.logout),
                    onTap: _logout),
              ],
            ),
          ),
          floatingActionButton: _fab(),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BannerAdWidget(),
              BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.dashboard), label: l.home),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.flight_takeoff), label: l.tripsLabel),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.account_balance_wallet), label: l.budget),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.checklist), label: l.bag),
                ],
              ),
            ],
          ),

          // IndexedStack garde chaque onglet en vie (le navigator imbriqué garde sa position)
          body: trips.error != null && !trips.isLoading && trips.trips.isEmpty
              ? ErrorView(message: l.errorLoading)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: IndexedStack(index: _index, children: pages),
                  ),
                ),
        ),
      ),
    );
  }
}

// Observe le navigator imbriqué pour savoir s'il peut revenir en arrière
class _TripsNavObserver extends NavigatorObserver {
  final VoidCallback onChanged;
  _TripsNavObserver(this.onChanged);

  @override
  void didPush(Route route, Route? previousRoute) => onChanged();

  @override
  void didPop(Route route, Route? previousRoute) => onChanged();

  @override
  void didRemove(Route route, Route? previousRoute) => onChanged();
}
