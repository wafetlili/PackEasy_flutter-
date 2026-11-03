import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/glass_card.dart';

class OverviewTab extends StatelessWidget {
  final void Function(int) onGo;
  const OverviewTab({super.key, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TripProvider>();
    final email = FirebaseAuth.instance.currentUser?.email ?? 'voyageur';
    final name = email.split('@').first;
    final trip = t.nextTrip;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Appear(
          index: 0,
          child: Text('Bonjour, $name 👋',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        const Appear(index: 1, child: Text('Prêt pour votre prochaine aventure ?')),
        const SizedBox(height: 16),

        Appear(
          index: 2,
          child: trip == null
              ? _EmptyTrip(onGo: onGo)
              : _NextTripCard(trip: trip),
        ),

        // Statistiques
        Appear(
          index: 3,
          child: Row(
            children: [
              Expanded(child: _Stat(Icons.flight_takeoff, 'Voyages', '${t.tripCount}')),
              const SizedBox(width: 10),
              Expanded(child: _Stat(Icons.euro, 'Dépensé', '${t.totalSpent.round()} €')),
              const SizedBox(width: 10),
              Expanded(
                  child: _Stat(Icons.checklist, 'Valise',
                      '${t.packedCount}/${t.items.length}')),
            ],
          ),
        ),

        // Accès rapides
        const SizedBox(height: 6),
        const Appear(
          index: 4,
          child: Text('Accès rapide',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Appear(
          index: 5,
          child: Row(
            children: [
              Expanded(
                child: _Action(Icons.public, 'Explorer', Colors.teal,
                    () => Navigator.pushNamed(context, '/home')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Action(Icons.account_balance_wallet, 'Budget', Colors.orange,
                    () => onGo(2)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Action(Icons.luggage, 'Valise', Colors.purple, () => onGo(3)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyTrip extends StatelessWidget {
  final void Function(int) onGo;
  const _EmptyTrip({required this.onGo});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.flight_takeoff, size: 56, color: Colors.orange),
          const SizedBox(height: 10),
          const Text('Aucun voyage prévu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Explorez les destinations ou créez votre premier voyage.',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.public),
                label: const Text('Explorer'),
                onPressed: () => Navigator.pushNamed(context, '/home'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Créer un voyage'),
                onPressed: () => onGo(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextTripCard extends StatelessWidget {
  final Trip trip;
  const _NextTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final left = trip.daysLeft;
    // L'avion avance sur les 30 derniers jours avant le départ
    final progress = (1 - left / 30).clamp(0.0, 1.0);
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
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
                    Text('${fmt.format(trip.start)} → ${fmt.format(trip.end)}'),
                  ],
                ),
              ),
              Chip(
                label: Text(left > 0
                    ? 'J-$left'
                    : left == 0
                        ? "Aujourd'hui"
                        : 'En cours'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Avion qui avance vers le départ
          LayoutBuilder(
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
                              color: primary, borderRadius: BorderRadius.circular(4)),
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
          const SizedBox(height: 8),
          Text('${trip.days} jours • Budget ${trip.budget} €'),
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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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