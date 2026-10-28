import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../widgets/travel_background.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  void _logout() async {
    await AuthService().signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  // Style commun (Glassmorphism)
  BoxDecoration _glassDecoration({Color? color}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
    );
  }

  // ==========================================
  // SECTION 1 : STATISTIQUES & VOYAGES À VENIR
  // ==========================================
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bonjour, Admin 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()), style: const TextStyle(color: Colors.black54)),
                ],
              ),
              const CircleAvatar(radius: 22, backgroundColor: Colors.red, child: Icon(Icons.admin_panel_settings, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),

          // Cartes de stats
          Row(
            children: [
              Expanded(child: _statCard("Utilisateurs", Icons.people, Colors.blue, 'users')),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Destinations", Icons.map, Colors.green, 'destinations')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard("Programmes", Icons.card_travel, Colors.orange, 'programs')),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Voyages", Icons.luggage, Colors.purple, 'trips')),
            ],
          ),
          const SizedBox(height: 24),

          // Départs imminents
          const Text("⏳ Départs imminents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('trips').orderBy('startDate').limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final trips = snapshot.data!.docs;
              if (trips.isEmpty) return const Text("Aucun voyage à venir.");

              return Column(
                children: trips.map((doc) {
                  final trip = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      leading: const Icon(Icons.flight_takeoff, color: Colors.purple),
                      title: Text(trip['title'] ?? 'Voyage', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Départ : ${trip['startDate']}'),
                      trailing: Text(trip['price'] != null ? '${trip['price']} €' : '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, Color color, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration().copyWith(border: Border.all(color: color.withOpacity(0.3), width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text("$count", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // SECTION 2 : DESTINATIONS
  // ==========================================
  Widget _buildDestinationsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_location),
            label: const Text("Ajouter une destination"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            onPressed: () => _showAddDestinationDialog(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('destinations').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("Aucune destination."));
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(data['image'] ?? ''), backgroundColor: Colors.grey),
                      title: Text(data['name'] ?? 'Sans nom'),
                      subtitle: Text(data['country'] ?? ''),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firestore.collection('destinations').doc(docs[index].id).delete()),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 3 : PROGRAMMES
  // ==========================================
  Widget _buildProgramsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_road),
            label: const Text("Créer un programme"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            onPressed: () => _showAddProgramDialog(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('programs').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("Aucun programme."));
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      leading: const Icon(Icons.card_travel, color: Colors.orange),
                      title: Text(data['title'] ?? 'Sans titre'),
                      subtitle: Text('${data['type']} • ${data['duration']} jours • ${data['price']} €'),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firestore.collection('programs').doc(docs[index].id).delete()),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4 : VOYAGES
  // ==========================================
  Widget _buildTripsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_location_alt),
            label: const Text("Ajouter un voyage"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
            onPressed: () => _showAddTripDialog(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('trips').orderBy('startDate').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("Aucun voyage planifié."));
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      leading: const Icon(Icons.luggage, color: Colors.purple),
                      title: Text(data['title'] ?? 'Voyage sans titre'),
                      subtitle: Text('Du ${data['startDate']} au ${data['endDate']} • ${data['destination']}'),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firestore.collection('trips').doc(docs[index].id).delete()),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 5 : UTILISATEURS
  // ==========================================
  Widget _buildUsersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final isAdmin = user['role'] == 'admin';
            return Card(
              color: Colors.white.withOpacity(0.8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: isAdmin ? Colors.red : Colors.grey, child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, color: Colors.white)),
                title: Text(user['email'] ?? 'Email'),
                subtitle: Text(isAdmin ? 'Administrateur' : 'Voyageur'),
                trailing: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: () => _firestore.collection('users').doc(users[index].id).delete()),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // FORMULAIRES (Dialogues)
  // ==========================================

  void _showAddDestinationDialog() {
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final flagCtrl = TextEditingController();
    final continentCtrl = TextEditingController();
    String selectedCategory = 'Ville';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Nouvelle Destination"),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nom")),
                TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: "Pays")),
                TextField(controller: flagCtrl, decoration: const InputDecoration(labelText: "Emoji Drapeau")),
                TextField(controller: continentCtrl, decoration: const InputDecoration(labelText: "Continent")),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Catégorie"),
                  items: ['Ville', 'Plage', 'Culture', 'Nature'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setStateDialog(() => selectedCategory = val!),
                ),
                TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "URL de l'image")),
                TextField(controller: budgetCtrl, decoration: const InputDecoration(labelText: "Budget (€)"), keyboardType: TextInputType.number),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () {
                  _firestore.collection('destinations').add({
                    'name': nameCtrl.text,
                    'country': countryCtrl.text,
                    'flag': flagCtrl.text.isNotEmpty ? flagCtrl.text : '🌍',
                    'continent': continentCtrl.text.isNotEmpty ? continentCtrl.text : 'Monde',
                    'category': selectedCategory,
                    'image': imageCtrl.text.isNotEmpty ? imageCtrl.text : 'https://via.placeholder.com/400',
                    'budget': int.tryParse(budgetCtrl.text) ?? 0,
                    'description': descCtrl.text.isNotEmpty ? descCtrl.text : 'Belle destination.',
                    'rating': 4.0,
                    'season': 'Toute l\'année',
                    'language': 'Local',
                    'currency': 'EUR',
                    'temp': '25°C',
                    'highlights': ['À découvrir'],
                  });
                  Navigator.pop(context);
                },
                child: const Text("Ajouter"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddProgramDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? selectedType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Nouveau Programme"),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Titre du programme")),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Type de programme"),
                  items: ['Séminaire', 'Voyage de groupe', 'Tour d\'Europe', 'Aventure', 'Détente'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setStateDialog(() => selectedType = val),
                ),
                TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: "Durée (jours)"), keyboardType: TextInputType.number),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Prix (€)"), keyboardType: TextInputType.number),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () {
                  _firestore.collection('programs').add({
                    'title': titleCtrl.text,
                    'description': descCtrl.text,
                    'type': selectedType ?? 'Autre',
                    'duration': int.tryParse(durationCtrl.text) ?? 0,
                    'price': int.tryParse(priceCtrl.text) ?? 0,
                  });
                  Navigator.pop(context);
                },
                child: const Text("Créer"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTripDialog() {
    final titleCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouveau Voyage"),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Titre du voyage")),
            TextField(controller: destCtrl, decoration: const InputDecoration(labelText: "Destination")),
            TextField(controller: startCtrl, decoration: const InputDecoration(labelText: "Date de début (JJ/MM/AAAA)")),
            TextField(controller: endCtrl, decoration: const InputDecoration(labelText: "Date de fin (JJ/MM/AAAA)")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Prix (€)"), keyboardType: TextInputType.number),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              _firestore.collection('trips').add({
                'title': titleCtrl.text,
                'destination': destCtrl.text,
                'startDate': startCtrl.text,
                'endDate': endCtrl.text,
                'price': int.tryParse(priceCtrl.text) ?? 0,
                'description': descCtrl.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD PRINCIPAL AVEC APPBAR FINE ET TRANSPARENTE
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildStatsTab(),
      _buildDestinationsTab(),
      _buildProgramsTab(),
      _buildTripsTab(),
      _buildUsersTab(),
    ];

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // --- APPBAR FINE ET TRANSPARENTE ---
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              border: Border(bottom: BorderSide(color: Colors.teal.withOpacity(0.2), width: 1)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.teal),
              title: Row(
                children: [
                  const _AnimatedPlane(),
                  const SizedBox(width: 8),
                  const Text(
                    "Admin PackEasy",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.teal),
                  tooltip: "Retour à l'accueil",
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.teal),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucune notification")));
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        // -------------------------------------------
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF26A69A), Color(0xFF4DD0E1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text("Administrateur", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              _drawerItem(Icons.dashboard, "Tableau de bord", 0),
              _drawerItem(Icons.map, "Destinations", 1),
              _drawerItem(Icons.card_travel, "Programmes", 2),
              _drawerItem(Icons.luggage, "Voyages", 3),
              _drawerItem(Icons.people, "Utilisateurs", 4),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.teal),
                title: const Text("Retour à l'application", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.teal.shade700,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.white.withOpacity(0.9),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Stats"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Destinations"),
            BottomNavigationBarItem(icon: Icon(Icons.card_travel), label: "Programmes"),
            BottomNavigationBarItem(icon: Icon(Icons.luggage), label: "Voyages"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

// --- WIDGET ANIMÉ (L'avion qui bouge) ---
class _AnimatedPlane extends StatefulWidget {
  const _AnimatedPlane();

  @override
  State<_AnimatedPlane> createState() => _AnimatedPlaneState();
}

class _AnimatedPlaneState extends State<_AnimatedPlane> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value, 
          child: const Icon(Icons.flight, color: Colors.teal, size: 22),
        );
      },
    );
  }
}