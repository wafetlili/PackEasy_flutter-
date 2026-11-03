import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/glass_card.dart';

class TripsTab extends StatelessWidget {
  const TripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TripProvider>();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'À venir'), Tab(text: 'Historique')]),
          Expanded(
            child: TabBarView(
              children: [
                _TripList(trips: t.upcoming, empty: 'Aucun voyage à venir'),
                _TripList(trips: t.history, empty: 'Aucun voyage passé'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final List<Trip> trips;
  final String empty;
  const _TripList({required this.trips, required this.empty});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.luggage, size: 70),
            const SizedBox(height: 8),
            Text(empty),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: trips.length,
      itemBuilder: (context, i) =>
          Appear(index: i, child: _TripCard(trip: trips[i])),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final left = trip.daysLeft;

    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(trip.flag, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.destination,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${fmt.format(trip.start)} → ${fmt.format(trip.end)}'),
                Text('${trip.days} jours • ${trip.budget} €',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          if (!trip.isPast && left > 0) Chip(label: Text('J-$left')),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<TripProvider>().removeTrip(trip.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Voyage vers ${trip.destination} supprimé')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------- Formulaire : nouveau voyage ----------
void showAddTripSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const _TripForm(),
    ),
  );
}

class _TripForm extends StatefulWidget {
  const _TripForm();

  @override
  State<_TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<_TripForm> {
  final _formKey = GlobalKey<FormState>();
  final _dest = TextEditingController();
  final _budget = TextEditingController();
  DateTimeRange? _range;
  bool _rangeError = false;

  @override
  void dispose() {
    _dest.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (r != null) setState(() {
      _range = r;
      _rangeError = false;
    });
  }

  void _submit() {
    final ok = _formKey.currentState!.validate();
    if (_range == null) setState(() => _rangeError = true);
    if (!ok || _range == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final name = _dest.text.trim();
    context.read<TripProvider>().addTrip(Trip(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          destination: name,
          start: _range!.start,
          end: _range!.end,
          budget: int.parse(_budget.text.trim()),
        ));
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('Voyage vers $name créé ✈️')));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouveau voyage',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dest,
              decoration: const InputDecoration(
                labelText: 'Destination',
                prefixIcon: Icon(Icons.place),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Entrez une destination (2 caractères minimum)'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget (€)',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n <= 0) ? 'Entrez un budget valide (nombre > 0)' : null;
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              onPressed: _pickRange,
              label: Text(_range == null
                  ? 'Choisir les dates'
                  : '${fmt.format(_range!.start)} → ${fmt.format(_range!.end)}'),
            ),
            if (_rangeError)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 12),
                child: Text('Choisissez les dates du voyage',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Créer le voyage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}