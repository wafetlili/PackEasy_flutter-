// ============================================================
// packing_tab.dart
// Onglet "Valise" : liste d'objets à emporter (Firestore).
// Glisser vers le côté pour supprimer, cocher pour préparer.
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/trip_provider.dart';
import '../../utils/l10n_ext.dart';
import '../../utils/labels.dart';
import '../../utils/ui.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/state_views.dart';

class PackingTab extends StatelessWidget {
  const PackingTab({super.key});

  // Suggestions rapides (traduites selon la langue)
  List<String> _suggestions(AppLocalizations l) => [
        l.sugPassport,
        l.sugCharger,
        l.sugToiletries,
        l.sugClothes,
        l.sugUmbrella,
        l.sugSwimsuit,
        l.sugAdapter,
        l.sugSunglasses,
        l.sugSunscreen,
        l.sugMedicine,
        l.sugHeadphones,
        l.sugBankCard,
      ];

  // Exécute une action Firestore et affiche l'erreur éventuelle
  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        showMessage(context, errorMessage(context.l10n, e), error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.watch<TripProvider>();

    if (t.isLoading) return LoadingView(message: l.loading);

    final items = t.items;
    final total = items.length;
    final done = t.packedCount;
    final ratio = total == 0 ? 0.0 : done / total;
    final ready = total > 0 && done == total;
    final missing = _suggestions(l).where((s) => !t.hasItem(s)).take(5).toList();

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
                    ready ? l.readyToFly : l.packedCount(done, total),
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
                    onPressed: () => _run(context, () => t.addItem(s)),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        if (items.isEmpty)
          SizedBox(
            height: 200,
            child: EmptyView(icon: Icons.luggage, title: l.bagEmpty),
          ),

        // Liste (glisser pour supprimer)
        for (final item in items)
          Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _run(context, () => t.removeItem(item)),
            background: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsetsDirectional.only(end: 20),
              alignment: AlignmentDirectional.centerEnd,
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
                onChanged: (_) => _run(context, () => t.toggleItem(item)),
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
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final provider = context.read<TripProvider>();
  final l = context.l10n;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.addItem),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.itemHint),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l.errorRequired;
            if (provider.hasItem(v.trim())) return l.errorItemExists;
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final navigator = Navigator.of(ctx);
            try {
              await provider.addItem(controller.text.trim());
              navigator.pop();
            } catch (e) {
              if (ctx.mounted) showMessage(ctx, errorMessage(l, e), error: true);
            }
          },
          child: Text(l.add),
        ),
      ],
    ),
  ).then((_) => controller.dispose());
}
