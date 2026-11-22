// ============================================================
// budget_tab.dart
// Onglet "Budget" : budget du prochain voyage, dépenses par
// catégorie et liste des dépenses (Firestore, temps réel).
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

// Catégories de dépenses : code -> (icône, couleur)
const Map<String, (IconData, Color)> expenseCategories = {
  'transport': (Icons.flight, Colors.blue),
  'lodging': (Icons.hotel, Colors.purple),
  'food': (Icons.restaurant, Colors.orange),
  'activities': (Icons.local_activity, Colors.green),
  'other': (Icons.more_horiz, Colors.grey),
};

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.watch<TripProvider>();
    final trip = t.nextTrip;

    if (t.isLoading) return LoadingView(message: l.loading);

    // Pas de voyage : état vide
    if (trip == null) {
      return EmptyView(
        icon: Icons.account_balance_wallet,
        title: l.createFirstTrip,
        subtitle: l.budgetLinked,
      );
    }

    final spent = t.spentOn(trip.id);
    final budget = trip.budget;
    final left = budget - spent;
    final ratio = budget == 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final color = ratio > 0.9 ? Colors.red : (ratio > 0.6 ? Colors.orange : Colors.green);
    final expenses = t.expensesOf(trip.id);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Résumé avec cercle animé
        Appear(
          index: 0,
          child: GlassCard(
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    builder: (context, v, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            value: v,
                            strokeWidth: 10,
                            color: color,
                            backgroundColor: color.withAlpha(40),
                          ),
                        ),
                        Text('${(v * 100).round()}%',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.flag} ${trip.destination}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(l.budgetOf(budget)),
                      Text(l.spentOf(spent.round())),
                      Text(
                        left >= 0 ? l.remaining(left.round()) : l.overBudget((-left).round()),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Barres par catégorie
        Appear(
          index: 1,
          child: Text(l.byCategory,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Appear(
          index: 2,
          child: GlassCard(
            child: Column(
              children: [
                for (final e in expenseCategories.entries)
                  _CategoryBar(
                    label: expenseLabel(l, e.key),
                    icon: e.value.$1,
                    color: e.value.$2,
                    amount: t.spentIn(trip.id, e.key),
                    budget: budget,
                  ),
              ],
            ),
          ),
        ),

        // Liste des dépenses
        const SizedBox(height: 6),
        Appear(
          index: 3,
          child: Text(l.expenses,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        if (expenses.isEmpty)
          GlassCard(child: Center(child: Text(l.noExpense))),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('-${e.amount.toStringAsFixed(0)} €',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      try {
                        await context.read<TripProvider>().removeExpense(e.id);
                      } catch (err) {
                        if (context.mounted) {
                          showMessage(context, errorMessage(l, err), error: true);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double amount;
  final int budget;

  const _CategoryBar({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = budget == 0 ? 0.0 : (amount / budget).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
              Text('${amount.round()} €',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: color,
                backgroundColor: color.withAlpha(40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Formulaire : ajouter une dépense ----------
// [trip] : voyage concerné (par défaut : le prochain voyage)
void showAddExpenseSheet(BuildContext context, {Trip? trip}) {
  final target = trip ?? context.read<TripProvider>().nextTrip;
  if (target == null) {
    showMessage(context, context.l10n.createFirstTrip);
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ExpenseForm(trip: target),
    ),
  );
}

class _ExpenseForm extends StatefulWidget {
  final Trip trip;
  const _ExpenseForm({required this.trip});

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _amount = TextEditingController();
  String _category = 'transport';
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    try {
      await context.read<TripProvider>().addExpense(Expense(
            id: '',
            tripId: widget.trip.id,
            label: _label.text.trim(),
            category: _category,
            amount: double.parse(_amount.text.trim().replaceAll(',', '.')),
            date: DateTime.now(),
          ));
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l.expenseAdded)));
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
            Text(l.addExpense,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _label,
              decoration: InputDecoration(
                labelText: l.description,
                prefixIcon: const Icon(Icons.edit),
                border: const OutlineInputBorder(),
              ),
              validator: v.required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.amountEuro,
                prefixIcon: const Icon(Icons.euro),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => v.positiveNumber(value, message: l.errorAmount),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l.category,
                prefixIcon: const Icon(Icons.category),
                border: const OutlineInputBorder(),
              ),
              items: expenseCategories.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(expenseLabel(l, c))))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
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
                    : Text(l.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
