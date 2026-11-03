import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/trip.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/glass_card.dart';

const Map<String, (IconData, Color)> expenseCategories = {
  'Transport': (Icons.flight, Colors.blue),
  'Hébergement': (Icons.hotel, Colors.purple),
  'Nourriture': (Icons.restaurant, Colors.orange),
  'Activités': (Icons.local_activity, Colors.green),
  'Autres': (Icons.more_horiz, Colors.grey),
};

class BudgetTab extends StatelessWidget {
  const BudgetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TripProvider>();
    final trip = t.nextTrip;

    // Pas de voyage : état vide
    if (trip == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: GlassCard(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 56),
                SizedBox(height: 10),
                Text("Créez d'abord un voyage",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Le budget est lié à votre prochain voyage.',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final spent = t.totalSpent;
    final budget = trip.budget;
    final left = budget - spent;
    final ratio = (spent / budget).clamp(0.0, 1.0);
    final color = ratio > 0.9 ? Colors.red : (ratio > 0.6 ? Colors.orange : Colors.green);
    final fmt = DateFormat('d MMM', 'fr_FR');
    final expenses = t.expenses;

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
                      Text('Budget : $budget €'),
                      Text('Dépensé : ${spent.round()} €'),
                      Text(
                        left >= 0
                            ? 'Reste : ${left.round()} €'
                            : 'Dépassement : ${(-left).round()} €',
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
        const Appear(
          index: 1,
          child: Text('Par catégorie',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Appear(
          index: 2,
          child: GlassCard(
            child: Column(
              children: [
                for (final e in expenseCategories.entries)
                  _CategoryBar(
                    label: e.key,
                    icon: e.value.$1,
                    color: e.value.$2,
                    amount: t.spentIn(e.key),
                    budget: budget,
                  ),
              ],
            ),
          ),
        ),

        // Liste des dépenses
        const SizedBox(height: 6),
        const Appear(
          index: 3,
          child: Text('Dépenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        if (expenses.isEmpty)
          const GlassCard(
            child: Center(child: Text('Aucune dépense pour le moment')),
          ),
        for (final e in expenses)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: expenseCategories[e.category]!.$2.withAlpha(40),
                child: Icon(expenseCategories[e.category]!.$1,
                    color: expenseCategories[e.category]!.$2),
              ),
              title: Text(e.label),
              subtitle: Text('${e.category} • ${fmt.format(e.date)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('-${e.amount.toStringAsFixed(0)} €',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context.read<TripProvider>().removeExpense(e.id),
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
    final ratio = (amount / budget).clamp(0.0, 1.0);
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
void showAddExpenseSheet(BuildContext context) {
  if (context.read<TripProvider>().nextTrip == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Créez d'abord un voyage")),
    );
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const _ExpenseForm(),
    ),
  );
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm();

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _amount = TextEditingController();
  String _category = 'Transport';

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    context.read<TripProvider>().addExpense(Expense(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          label: _label.text.trim(),
          category: _category,
          amount: double.parse(_amount.text.trim().replaceAll(',', '.')),
          date: DateTime.now(),
        ));
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Dépense ajoutée ✅')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajouter une dépense',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Entrez une description' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant (€)',
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                return (n == null || n <= 0) ? 'Entrez un montant valide (> 0)' : null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: expenseCategories.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(onPressed: _submit, child: const Text('Ajouter')),
            ),
          ],
        ),
      ),
    );
  }
}