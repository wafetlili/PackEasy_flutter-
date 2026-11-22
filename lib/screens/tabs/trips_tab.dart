// ============================================================
// trips_tab.dart
// Onglet "Voyages" : voyages à venir / historique (TabBar) et
// formulaire d'ajout d'un voyage. Données : Firestore.
// Un appui sur un voyage ouvre ses détails dans le navigator imbriqué.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../utils/l10n_ext.dart';
import '../../utils/labels.dart';
import '../../utils/ui.dart';
import '../../utils/validators.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/state_views.dart';

class TripsTab extends StatelessWidget {
  const TripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.watch<TripProvider>();

    if (t.isLoading) return LoadingView(message: l.loading);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [Tab(text: l.upcoming), Tab(text: l.history)]),
          Expanded(
            child: TabBarView(
              children: [
                _TripList(trips: t.upcoming, empty: l.noUpcomingTrips),
                _TripList(trips: t.history, empty: l.noPastTrips),
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
    if (trips.isEmpty) return EmptyView(icon: Icons.luggage, title: empty);

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

  // Supprime le voyage après confirmation
  Future<void> _delete(BuildContext context) async {
    final l = context.l10n;
    final provider = context.read<TripProvider>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(trip.destination),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await provider.removeTrip(trip.id);
      if (context.mounted) showMessage(context, l.tripDeleted(trip.destination));
    } catch (e) {
      if (context.mounted) showMessage(context, errorMessage(l, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final left = trip.daysLeft;

    return GlassCard(
      // Navigation imbriquée : on envoie le voyage en argument
      onTap: () => Navigator.of(context).pushNamed('/trip', arguments: trip),
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
                Text(
                    '${formatDate(context, trip.start)} → ${formatDate(context, trip.end)}'),
                Text(l.daysAndBudget(trip.days, trip.budget),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          if (!trip.isPast && left > 0) Chip(label: Text(l.daysLeft(left))),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context),
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
  bool _saving = false;

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
    if (r != null) {
      setState(() {
        _range = r;
        _rangeError = false;
      });
    }
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final ok = _formKey.currentState!.validate();
    if (_range == null) setState(() => _rangeError = true);
    if (!ok || _range == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _dest.text.trim();

    setState(() => _saving = true);
    try {
      await context.read<TripProvider>().addTrip(Trip(
            id: '',
            destination: name,
            start: _range!.start,
            end: _range!.end,
            budget: int.parse(_budget.text.trim()),
          ));
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l.tripCreated(name))));
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, errorMessage(l, e), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = Validators(l);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.newTrip,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dest,
              decoration: InputDecoration(
                labelText: l.destination,
                prefixIcon: const Icon(Icons.place),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().length < 2)
                  ? l.errorDestination
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.budgetEuro,
                prefixIcon: const Icon(Icons.euro),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => v.positiveInt(value, message: l.errorBudget),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              icon: const Icon(Icons.date_range),
              onPressed: _pickRange,
              label: Text(_range == null
                  ? l.chooseDates
                  : '${formatDate(context, _range!.start)} → ${formatDate(context, _range!.end)}'),
            ),
            if (_rangeError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
                child: Text(l.chooseDatesError,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.create),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
