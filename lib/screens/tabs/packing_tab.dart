import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/glass_card.dart';

class PackingTab extends StatelessWidget {
  const PackingTab({super.key});

  static const suggestions = [
    'Parapluie',
    'Maillot de bain',
    'Adaptateur de prise',
    'Lunettes de soleil',
    'Crème solaire',
    'Médicaments',
    'Écouteurs',
    'Carte bancaire',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TripProvider>();
    final items = t.items;
    final total = items.length;
    final done = t.packedCount;
    final ratio = total == 0 ? 0.0 : done / total;
    final ready = total > 0 && done == total;
    final missing = suggestions.where((s) => !t.hasItem(s)).take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Progression
        Appear(
          index: 0,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    ready ? 'Prêt au décollage ! ✈️' : '$done / $total objets préparés',
                    key: ValueKey(ready),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      color: ready ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Suggestions rapides
        if (missing.isNotEmpty)
          Appear(
            index: 1,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in missing)
                  ActionChip(
                    label: Text('+ $s'),
                    onPressed: () => context.read<TripProvider>().addItem(s),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        if (items.isEmpty)
          const GlassCard(child: Center(child: Text('Votre valise est vide'))),

        // Liste (glisser vers la gauche pour supprimer)
        for (final item in items)
          Dismissible(
            key: ValueKey(item),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => context.read<TripProvider>().removeItem(item),
            background: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: CheckboxListTile(
                value: item.checked,
                onChanged: (_) => context.read<TripProvider>().toggleItem(item),
                controlAffinity: ListTileControlAffinity.leading,
                title: AnimatedOpacity(
                  opacity: item.checked ? 0.5 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------- Dialogue : ajouter un objet ----------
void showAddItemDialog(BuildContext context) {
  final key = GlobalKey<FormState>();
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ajouter un objet'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex : Parapluie'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Entrez un nom';
            if (context.read<TripProvider>().hasItem(v.trim())) {
              return 'Cet objet existe déjà';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        FilledButton(
          onPressed: () {
            if (key.currentState!.validate()) {
              context.read<TripProvider>().addItem(controller.text.trim());
              Navigator.pop(ctx);
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    ),
  );
}