// ============================================================
// profile_screen.dart
// Profil de l'utilisateur : email, rôle, nom modifiable
// (formulaire validé) et déconnexion.
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../services/auth_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../utils/validators.dart';
import '../widgets/glass_card.dart';
import '../widgets/travel_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final AuthService _auth = AuthService();
  String _role = 'user';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    if (user != null) {
      _auth.getUserRole(user.uid).then((role) {
        if (mounted) setState(() => _role = role);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _saving = true);
    try {
      await _auth.updateName(_nameController.text.trim());
      if (mounted) showMessage(context, l.profileUpdated);
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = FirebaseAuth.instance.currentUser;
    final trips = context.watch<TripProvider>();

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l.profile),
        ),
        body: user == null
            ? Center(
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(l.login),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GlassCard(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(
                                (user.email ?? '?')[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(user.email ?? '',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                  '${l.role} : ${_role == 'admin' ? l.admin : l.user}'),
                            ),
                            Text('${l.tripsLabel} : ${trips.tripCount}'),
                          ],
                        ),
                      ),

                      // Formulaire de modification du nom
                      GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: l.fullName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) => Validators(l).minLength(v, 2) == null
                                    ? null
                                    : l.errorName,
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton(
                                  onPressed: _saving ? null : _save,
                                  child: _saving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : Text(l.save),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: Text(l.settings),
                        onPressed: () => Navigator.pushNamed(context, '/settings'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: Text(l.logout,
                            style: const TextStyle(color: Colors.red)),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
