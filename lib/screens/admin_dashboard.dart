// ============================================================
// admin_dashboard.dart
// Tableau de bord de l'administrateur : statistiques, gestion
// des destinations, programmes, voyages et utilisateurs.
// Tout est lu et écrit dans Firestore. Les formulaires sont
// validés et affichent des messages d'erreur clairs.
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../services/destination_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/state_views.dart';
import '../widgets/travel_background.dart';

// Raccourci de type pour les documents Firestore
typedef Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Index de l'onglet actif dans la BottomNavigationBar
  int _selectedIndex = 0;

  // Déconnexion de l'administrateur
  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  // Style "verre" des cartes (couleurs du thème : lisible en clair et en sombre)
  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15),
      ],
    );
  }

  // Supprime un document après confirmation
  Future<void> _confirmDelete(DocumentReference<Map<String, dynamic>> ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.delete().timeout(const Duration(seconds: 10));
      if (mounted) showMessage(context, l.deleted);
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    }
  }

  // ------------------------------------------------------------
  // Onglet de gestion générique : bouton d'ajout + liste Firestore
  // (gère chargement, erreur et liste vide)
  // ------------------------------------------------------------
  Widget _managedList({
    required Query<Map<String, dynamic>> query,
    required String addLabel,
    required IconData addIcon,
    required VoidCallback onAdd,
    required String emptyText,
    required IconData emptyIcon,
    required Widget Function(Doc doc) tile,
    Widget? extraButton,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ElevatedButton.icon(
            icon: Icon(addIcon),
            label: Text(addLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: onAdd,
          ),
        ),
        if (extraButton != null)
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: extraButton),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(message: context.l10n.errorLoading);
              }
              if (!snapshot.hasData) return const LoadingView();

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return EmptyView(icon: emptyIcon, title: emptyText);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) => Card(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  child: tile(docs[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION 1 : STATISTIQUES ET VOYAGES À VENIR
  // ============================================================
  Widget _buildStatsTab() {
    final l = context.l10n;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : salutation + date du jour (dans la langue choisie)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminGreeting,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(
                      formatDate(context, DateTime.now(), pattern: 'EEEE d MMMM yyyy'),
                      style: TextStyle(color: secondary),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.red,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Cartes de statistiques (nombre de documents de chaque collection)
          Row(
            children: [
              Expanded(child: _statCard(l.users, Icons.people, Colors.blue, 'users')),
              const SizedBox(width: 12),
              Expanded(
                  child: _statCard(l.destinations, Icons.map, Colors.green, 'destinations')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _statCard(l.programs, Icons.card_travel, Colors.orange, 'programs')),
              const SizedBox(width: 12),
              Expanded(child: _statCard(l.tripsLabel, Icons.luggage, Colors.purple, 'trips')),
            ],
          ),
          const SizedBox(height: 24),

          // Prochains départs
          Text(l.upcomingDepartures,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore.collection('trips').orderBy('startDate').limit(5).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(l.errorLoading);
              if (!snapshot.hasData) return const LoadingView();

              final trips = snapshot.data!.docs;
              if (trips.isEmpty) return Text(l.noUpcomingTrip);

              return Column(
                children: trips.map((doc) {
                  final trip = doc.data();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    child: ListTile(
                      leading: const Icon(Icons.flight_takeoff, color: Colors.purple),
                      title: Text(trip['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(l.departure('${trip['startDate'] ?? ''}')),
                      trailing: Text(
                        trip['price'] != null ? '${trip['price']} €' : '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
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

  // Carte de statistique : compte les documents d'une collection en temps réel
  Widget _statCard(String title, IconData icon, Color color, String collection) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _glassDecoration().copyWith(
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text('$count',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION 2 : DESTINATIONS
  // ============================================================
  Widget _buildDestinationsTab() {
    final l = context.l10n;
    return _managedList(
      query: _firestore.collection('destinations'),
      addLabel: l.addDestination,
      addIcon: Icons.add_location,
      onAdd: _showAddDestinationDialog,
      emptyText: l.noDestination,
      emptyIcon: Icons.map,
      // Importe les destinations d'exemple dans Firestore
      extraButton: OutlinedButton.icon(
        icon: const Icon(Icons.cloud_upload),
        label: Text(l.importSamples),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46)),
        onPressed: () async {
          try {
            final count = await DestinationService().importSamples();
            if (mounted) showMessage(context, l.samplesImported(count));
          } catch (e) {
            if (mounted) showMessage(context, errorMessage(l, e), error: true);
          }
        },
      ),
      tile: (doc) {
        final data = doc.data();
        final image = data['image'] ?? '';
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: image.isEmpty ? null : NetworkImage(image),
            onBackgroundImageError: image.isEmpty ? null : (_, __) {},
            child: image.isEmpty ? Text(data['flag'] ?? '🌍') : null,
          ),
          title: Text(data['name'] ?? ''),
          subtitle: Text(data['country'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(doc.reference),
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION 3 : PROGRAMMES
  // ============================================================
  Widget _buildProgramsTab() {
    final l = context.l10n;
    return _managedList(
      query: _firestore.collection('programs'),
      addLabel: l.addProgram,
      addIcon: Icons.add_road,
      onAdd: _showAddProgramDialog,
      emptyText: l.noProgram,
      emptyIcon: Icons.card_travel,
      tile: (doc) {
        final data = doc.data();
        final duration = ((data['duration'] ?? 0) as num).toInt();
        return ListTile(
          leading: const Icon(Icons.card_travel, color: Colors.orange),
          title: Text(data['title'] ?? ''),
          subtitle: Text(
              '${programTypeLabel(l, data['type'] ?? 'Autre')} - ${l.durationShort(duration)} - ${data['price'] ?? 0} €'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(doc.reference),
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION 4 : VOYAGES
  // ============================================================
  Widget _buildTripsTab() {
    final l = context.l10n;
    return _managedList(
      query: _firestore.collection('trips').orderBy('startDate'),
      addLabel: l.addTrip,
      addIcon: Icons.add_location_alt,
      onAdd: _showAddTripDialog,
      emptyText: l.noTrip,
      emptyIcon: Icons.luggage,
      tile: (doc) {
        final data = doc.data();
        return ListTile(
          leading: const Icon(Icons.luggage, color: Colors.purple),
          title: Text(data['title'] ?? ''),
          subtitle: Text(
              '${l.tripFromTo('${data['startDate'] ?? ''}', '${data['endDate'] ?? ''}')} - ${data['destination'] ?? ''}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(doc.reference),
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION 5 : UTILISATEURS
  // ============================================================
  Widget _buildUsersTab() {
    final l = context.l10n;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(message: l.errorLoading);
        if (!snapshot.hasData) return const LoadingView();

        final users = snapshot.data!.docs;
        if (users.isEmpty) return EmptyView(icon: Icons.people, title: l.users);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data();
            final isAdmin = user['role'] == 'admin';
            return Card(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAdmin ? Colors.red : Colors.grey,
                  child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white),
                ),
                title: Text(user['email'] ?? ''),
                subtitle: Text(isAdmin ? l.admin : l.user),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _confirmDelete(users[index].reference),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // FORMULAIRES (dialogues avec validation)
  // ============================================================

  // Dialogue de formulaire générique : valide, enregistre, affiche les erreurs
  Future<void> _formDialog({
    required String title,
    required GlobalKey<FormState> formKey,
    required List<Widget> Function(StateSetter setState) fields,
    required Future<void> Function() onSave,
  }) {
    final l = context.l10n;
    return showDialog(
      context: context,
      builder: (dialogContext) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setDialog) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: fields(setDialog)),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialog(() => saving = true);
                        try {
                          await onSave().timeout(const Duration(seconds: 10));
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) showMessage(context, l.saved);
                        } catch (e) {
                          setDialog(() => saving = false);
                          if (mounted) showMessage(context, errorMessage(l, e), error: true);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.save),
              ),
            ],
          ),
        );
      },
    );
  }

  // Espacement entre les champs
  static const _gap = SizedBox(height: 12);

  // Dialogue d'ajout d'une destination
  void _showAddDestinationDialog() {
    final l = context.l10n;
    final v = Validators(l);
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController();
    final flagCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String continent = 'Europe';
    String category = 'Ville';

    _formDialog(
      title: l.addDestination,
      formKey: formKey,
      fields: (setDialog) => [
        TextFormField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: l.name),
          validator: (value) => v.minLength(value, 2),
        ),
        _gap,
        TextFormField(
          controller: countryCtrl,
          decoration: InputDecoration(labelText: l.country),
          validator: (value) => v.minLength(value, 2),
        ),
        _gap,
        TextFormField(
          controller: flagCtrl,
          decoration: InputDecoration(labelText: l.flagEmoji),
        ),
        _gap,
        DropdownButtonFormField<String>(
          initialValue: continent,
          decoration: InputDecoration(labelText: l.continent),
          items: ['Afrique', 'Europe', 'Asie', 'Amérique', 'Océanie']
              .map((c) => DropdownMenuItem(value: c, child: Text(continentLabel(l, c))))
              .toList(),
          onChanged: (value) => setDialog(() => continent = value!),
        ),
        _gap,
        DropdownButtonFormField<String>(
          initialValue: category,
          decoration: InputDecoration(labelText: l.category),
          items: ['Ville', 'Plage', 'Culture', 'Nature']
              .map((c) => DropdownMenuItem(value: c, child: Text(categoryLabel(l, c))))
              .toList(),
          onChanged: (value) => setDialog(() => category = value!),
        ),
        _gap,
        TextFormField(
          controller: imageCtrl,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(labelText: l.imageUrl),
          validator: v.optionalUrl,
        ),
        _gap,
        TextFormField(
          controller: budgetCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.budgetEuro),
          validator: (value) => v.positiveInt(value, message: l.errorBudget),
        ),
        _gap,
        TextFormField(
          controller: descCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: l.description),
          validator: (value) => v.minLength(value, 10),
        ),
      ],
      onSave: () => _firestore.collection('destinations').add({
        'name': nameCtrl.text.trim(),
        'country': countryCtrl.text.trim(),
        'flag': flagCtrl.text.trim().isNotEmpty ? flagCtrl.text.trim() : '🌍',
        'continent': continent,
        'category': category,
        'image': imageCtrl.text.trim(),
        'budget': int.parse(budgetCtrl.text.trim()),
        'description': descCtrl.text.trim(),
        'rating': 4.0,
        'season': '',
        'language': '',
        'currency': 'EUR',
        'temp': '',
        'highlights': <String>[],
      }),
    ).whenComplete(() {
      for (final c in [nameCtrl, countryCtrl, flagCtrl, imageCtrl, budgetCtrl, descCtrl]) {
        c.dispose();
      }
    });
  }

  // Dialogue de création d'un programme
  void _showAddProgramDialog() {
    final l = context.l10n;
    final v = Validators(l);
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String type = programTypes.first;

    _formDialog(
      title: l.addProgram,
      formKey: formKey,
      fields: (setDialog) => [
        TextFormField(
          controller: titleCtrl,
          decoration: InputDecoration(labelText: l.programTitle),
          validator: (value) => v.minLength(value, 3),
        ),
        _gap,
        TextFormField(
          controller: descCtrl,
          maxLines: 2,
          decoration: InputDecoration(labelText: l.description),
          validator: v.required,
        ),
        _gap,
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: InputDecoration(labelText: l.programType),
          items: programTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(programTypeLabel(l, t))))
              .toList(),
          onChanged: (value) => setDialog(() => type = value!),
        ),
        _gap,
        TextFormField(
          controller: durationCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.durationField),
          validator: (value) => v.positiveInt(value),
        ),
        _gap,
        TextFormField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.priceEuro),
          validator: (value) => v.positiveInt(value),
        ),
      ],
      onSave: () => _firestore.collection('programs').add({
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'type': type,
        'duration': int.parse(durationCtrl.text.trim()),
        'price': int.parse(priceCtrl.text.trim()),
      }),
    ).whenComplete(() {
      for (final c in [titleCtrl, descCtrl, durationCtrl, priceCtrl]) {
        c.dispose();
      }
    });
  }

  // Dialogue d'ajout d'un voyage
  void _showAddTripDialog() {
    final l = context.l10n;
    final v = Validators(l);
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    _formDialog(
      title: l.addTrip,
      formKey: formKey,
      fields: (setDialog) => [
        TextFormField(
          controller: titleCtrl,
          decoration: InputDecoration(labelText: l.tripTitle),
          validator: (value) => v.minLength(value, 3),
        ),
        _gap,
        TextFormField(
          controller: destCtrl,
          decoration: InputDecoration(labelText: l.destination),
          validator: (value) => v.minLength(value, 2),
        ),
        _gap,
        TextFormField(
          controller: startCtrl,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: l.startDate, hintText: '25/12/2026'),
          validator: v.date,
        ),
        _gap,
        TextFormField(
          controller: endCtrl,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(labelText: l.endDate, hintText: '30/12/2026'),
          validator: (value) => v.endDate(value, startCtrl.text),
        ),
        _gap,
        TextFormField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.priceEuro),
          validator: (value) => v.positiveInt(value),
        ),
        _gap,
        TextFormField(
          controller: descCtrl,
          maxLines: 2,
          decoration: InputDecoration(labelText: l.description),
          validator: v.required,
        ),
      ],
      onSave: () => _firestore.collection('trips').add({
        'title': titleCtrl.text.trim(),
        'destination': destCtrl.text.trim(),
        'startDate': startCtrl.text.trim(),
        'endDate': endCtrl.text.trim(),
        'price': int.parse(priceCtrl.text.trim()),
        'description': descCtrl.text.trim(),
      }),
    ).whenComplete(() {
      for (final c in [titleCtrl, destCtrl, startCtrl, endCtrl, priceCtrl, descCtrl]) {
        c.dispose();
      }
    });
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final pages = [
      _buildStatsTab(),
      _buildDestinationsTab(),
      _buildProgramsTab(),
      _buildTripsTab(),
      _buildUsersTab(),
    ];

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // AppBar fine
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.88),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Row(
                children: [
                  const _AnimatedPlane(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.adminTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.home),
                  tooltip: l.backToApp,
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => showMessage(context, l.noNotification),
                ),
              ],
            ),
          ),
        ),

        // Drawer de navigation
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF26A69A), Color(0xFF4DD0E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      l.admin,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.dashboard, l.dashboard, 0),
              _drawerItem(Icons.map, l.destinations, 1),
              _drawerItem(Icons.card_travel, l.programs, 2),
              _drawerItem(Icons.luggage, l.tripsLabel, 3),
              _drawerItem(Icons.people, l.users, 4),
              const Divider(),

              // Thème clair / sombre
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
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.teal),
                title: Text(l.backToApp,
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(l.logout,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: _logout,
              ),
            ],
          ),
        ),

        body: pages[_selectedIndex],

        // Barre de navigation inférieure
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: scheme.primary,
          unselectedItemColor: scheme.onSurfaceVariant,
          backgroundColor: scheme.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: l.dashboard),
            BottomNavigationBarItem(icon: const Icon(Icons.map), label: l.destinations),
            BottomNavigationBarItem(icon: const Icon(Icons.card_travel), label: l.programs),
            BottomNavigationBarItem(icon: const Icon(Icons.luggage), label: l.tripsLabel),
            BottomNavigationBarItem(icon: const Icon(Icons.people), label: l.users),
          ],
        ),
      ),
    );
  }

  // Élément de menu réutilisable pour le Drawer
  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

// ============================================================
// Widget anime : petit avion qui oscille dans l'AppBar
// ============================================================
class _AnimatedPlane extends StatefulWidget {
  const _AnimatedPlane();

  @override
  State<_AnimatedPlane> createState() => _AnimatedPlaneState();
}

class _AnimatedPlaneState extends State<_AnimatedPlane>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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