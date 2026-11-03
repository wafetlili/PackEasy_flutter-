import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/travel_background.dart';
import 'tabs/overview_tab.dart';
import 'tabs/trips_tab.dart';
import 'tabs/budget_tab.dart';
import 'tabs/packing_tab.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _index = 0;
  final _titles = ['Mon espace voyageur', 'Mes voyages', 'Budget', 'Ma valise'];

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _go(int i) {
    setState(() => _index = i);
    Navigator.pop(context); // ferme le Drawer
  }

  // Bouton d'action selon l'onglet
  Widget? _fab() {
    switch (_index) {
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => showAddTripSheet(context),
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Nouveau voyage'),
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () => showAddExpenseSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Dépense'),
        );
      case 3:
        return FloatingActionButton.extended(
          onPressed: () => showAddItemDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Objet'),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Voyageur';
    final pages = [
      OverviewTab(onGo: (i) => setState(() => _index = i)),
      const TripsTab(),
      const BudgetTab(),
      const PackingTab(),
    ];

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(_titles[_index],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              tooltip: 'Explorer les destinations',
              icon: const Icon(Icons.explore),
              onPressed: () => Navigator.pushNamed(context, '/home'),
            ),
            IconButton(
              tooltip: 'Déconnexion',
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
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
                  title: const Text('Mon espace'),
                  onTap: () => _go(0)),
              ListTile(
                  leading: const Icon(Icons.flight_takeoff),
                  title: const Text('Mes voyages'),
                  onTap: () => _go(1)),
              ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Budget'),
                  onTap: () => _go(2)),
              ListTile(
                  leading: const Icon(Icons.checklist),
                  title: const Text('Ma valise'),
                  onTap: () => _go(3)),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('Explorer les destinations'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/home');
                },
              ),
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: _logout),
            ],
          ),
        ),
        floatingActionButton: _fab(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.flight_takeoff), label: 'Voyages'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
            BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Valise'),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
            ),
          ),
        ),
      ),
    );
  }
}