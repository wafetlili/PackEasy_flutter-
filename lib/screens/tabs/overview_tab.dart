// ============================================================
// overview_tab.dart
// Onglet "Accueil" de l'espace voyageur : prochain voyage,
// statistiques et accès rapides (données Firestore).
// ============================================================
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../utils/l10n_ext.dart';
import '../../utils/ui.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/state_views.dart';

class OverviewTab extends StatelessWidget {
  final void Function(int) onGo;
  const OverviewTab({super.key, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.watch<TripProvider>();
    final user = FirebaseAuth.instance.currentUser;
    // Nom affiché : nom du profil, sinon début de l'email
    final name = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email ?? l.user).split('@').first;
    final trip = t.nextTrip;

    if (t.isLoading) return LoadingView(message: l.loading);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Appear(
          index: 0,
          child: Text(l.hello(name),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Appear(index: 1, child: Text(l.readyAdventure)),
        const SizedBox(height: 16),

        Appear(
          index: 2,
          child: trip == null ? _EmptyTrip(onGo: onGo) : _NextTripCard(trip: trip),
        ),

        // Statistiques calculées avec les données de l'utilisateur
        Appear(
          index: 3,
          child: Row(
            children: [
              Expanded(child: _Stat(Icons.flight_takeoff, l.tripsLabel, '${t.tripCount}')),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(Icons.euro, l.spent,
                    '${trip == null ? 0 : t.spentOn(trip.id).round()} €'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(Icons.checklist, l.bag, '${t.packedCount}/${t.items.length}'),
              ),
            ],
          ),
        ),

        // Accès rapides
        const SizedBox(height: 6),
        Appear(
          index: 4,
          child: Text(l.quickAccess,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Appear(
          index: 5,
          child: Row(
            children: [
              Expanded(
                child: _Action(Icons.public, l.explore, Colors.teal,
                    () => Navigator.pushNamed(context, '/home')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Action(Icons.account_balance_wallet, l.budget, Colors.orange,
                    () => onGo(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Action(Icons.luggage, l.bag, Colors.purple, () => onGo(3)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Carte affichée quand il n'y a aucun voyage
class _EmptyTrip extends StatelessWidget {
  final void Function(int) onGo;
  const _EmptyTrip({required this.onGo});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.flight_takeoff, size: 56, color: Colors.orange),
          const SizedBox(height: 10),
          Text(l.noTripPlanned,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(l.noTripHint, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.public),
                label: Text(l.explore),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l.newTrip),
                onPressed: () => onGo(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Carte du prochain voyage avec avion animé
class _NextTripCard extends StatelessWidget {
  final Trip trip;
  const _NextTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final left = trip.daysLeft;
    // L'avion avance pendant les 30 derniers jours avant le départ
    final progress = (1 - left / 30).clamp(0.0, 1.0);
    final primary = Theme.of(context).colorScheme.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(trip.flag, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.destination,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(
                        '${formatDate(context, trip.start)} → ${formatDate(context, trip.end)}'),
                  ],
                ),
              ),
              Chip(
                label: Text(left > 0
                    ? l.daysLeft(left)
                    : left == 0
                        ? l.today
                        : l.ongoing),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // La barre reste de gauche à droite même en arabe (animation de l'avion)
          Directionality(
            textDirection: TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, c) => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) {
                  final planeX = (c.maxWidth - 30) * v;
                  return SizedBox(
                    height: 36,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 16,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 16,
                          child: Container(
                            width: planeX + 15,
                            height: 4,
                            decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const Positioned(
                          right: 0,
                          top: 4,
                          child: Icon(Icons.location_on, color: Colors.red, size: 28),
                        ),
                        Positioned(
                          left: planeX,
                          top: 0,
                          child: Transform.rotate(
                            angle: pi / 2,
                            child: const Icon(Icons.flight,
                                size: 30, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.daysAndBudget(trip.days, trip.budget)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Stat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Action(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
