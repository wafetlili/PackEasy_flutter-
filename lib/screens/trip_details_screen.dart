// ============================================================
// trip_details_screen.dart
// Détails d'un voyage de l'utilisateur.
// Ouvert dans le navigator IMBRIQUÉ de l'onglet "Voyages"
// (route '/trip', le voyage est passé en argument).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../widgets/glass_card.dart';
import '../widgets/state_views.dart';
import 'tabs/budget_tab.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  // Supprime le voyage puis revient à la liste
  Future<void> _delete(BuildContext context, Trip t) async {
    final l = context.l10n;
    final provider = context.read<TripProvider>();
    final navigator = Navigator.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(t.destination),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await provider.removeTrip(t.id);
      navigator.pop();
    } catch (e) {
      if (context.mounted) showMessage(context, errorMessage(l, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<TripProvider>();

    // On relit le voyage dans le provider pour avoir les données à jour
    final t = provider.tripById(trip.id) ?? trip;
    final expenses = provider.expensesOf(t.id);
    final spent = provider.spentOn(t.id);
    final ratio = t.budget == 0 ? 0.0 : (spent / t.budget).clamp(0.0, 1.0);
    final color = ratio > 0.9 ? Colors.red : (ratio > 0.6 ? Colors.orange : Colors.green);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(l.tripDetails),
        actions: [
          IconButton(
            tooltip: l.deleteTrip,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, t),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddExpenseSheet(context, trip: t),
        icon: const Icon(Icons.add),
        label: Text(l.expense),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          // Résumé du voyage
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(t.flag, style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(t.destination,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Line(Icons.date_range, l.dates,
                    '${formatDate(context, t.start)} → ${formatDate(context, t.end)}'),
                _Line(Icons.timelapse, l.durationDays(t.days), ''),
                if (!t.isPast && t.daysLeft > 0)
                  _Line(Icons.flight_takeoff, l.daysLeft(t.daysLeft), ''),
              ],
            ),
          ),

          // Budget de ce voyage
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.budget,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      color: color,
                      backgroundColor: color.withAlpha(40),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${l.budgetOf(t.budget)}  |  ${l.spentOf(spent.round())}'),
              ],
            ),
          ),

          // Dépenses de ce voyage
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(l.tripExpenses,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          if (expenses.isEmpty)
            SizedBox(
              height: 160,
              child: EmptyView(icon: Icons.receipt_long, title: l.noExpense),
            ),
          for (final e in expenses)
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: expenseCategories[e.category]?.$2.withAlpha(40),
                  child: Icon(expenseCategories[e.category]?.$1 ?? Icons.more_horiz,
                      color: expenseCategories[e.category]?.$2),
                ),
                title: Text(e.label),
                subtitle: Text(
                    '${expenseLabel(l, e.category)} • ${formatDate(context, e.date, pattern: 'd MMM')}'),
                trailing: Text('-${e.amount.toStringAsFixed(0)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _Line(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? title : '$title : $value')),
        ],
      ),
    );
  }
}
