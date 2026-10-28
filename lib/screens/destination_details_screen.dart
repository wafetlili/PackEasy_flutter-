import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_image.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key});

  @override
  State<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  bool _show = false; // déclenche les animations après l'arrivée de l'avion

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Argument reçu via la route nommée
    final d = ModalRoute.of(context)!.settings.arguments as Destination;
    final provider = context.watch<DestinationProvider>();
    final isFav = provider.isFavorite(d.id);
    const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    // Répartition indicative du budget
    final parts = [
      ('Transport', Icons.flight, 0.35, Colors.blue),
      ('Hébergement', Icons.hotel, 0.30, Colors.purple),
      ('Nourriture', Icons.restaurant, 0.20, Colors.orange),
      ('Activités', Icons.local_activity, 0.15, Colors.green),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null),
                onPressed: () => provider.toggleFavorite(d.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text('${d.flag} ${d.name}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  DestinationImage(destination: d, height: 320),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d.name}, ${d.country}',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text(d.continent)),
                          Chip(label: Text(d.category)),
                          Chip(label: Text('⭐ ${d.rating}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(d.description, style: const TextStyle(fontSize: 16)),

                      // Infos pratiques
                      const SizedBox(height: 24),
                      const Text('Infos pratiques', style: titleStyle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InfoTile(Icons.wb_sunny, 'Meilleure saison', d.season),
                          _InfoTile(Icons.thermostat, 'Température moyenne', d.temp),
                          _InfoTile(Icons.translate, 'Langues', d.language),
                          _InfoTile(Icons.payments, 'Monnaie', d.currency),
                        ],
                      ),

                      // Points forts
                      const SizedBox(height: 24),
                      const Text('À ne pas manquer', style: titleStyle),
                      const SizedBox(height: 8),
                      for (int i = 0; i < d.highlights.length; i++)
                        AnimatedOpacity(
                          opacity: _show ? 1 : 0,
                          duration: Duration(milliseconds: 500 + i * 250),
                          child: AnimatedSlide(
                            offset: _show ? Offset.zero : const Offset(0.2, 0),
                            duration: Duration(milliseconds: 500 + i * 250),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Text('${i + 1}')),
                                title: Text(d.highlights[i]),
                              ),
                            ),
                          ),
                        ),

                      // Budget
                      const SizedBox(height: 24),
                      Text('Budget indicatif : ~${d.budget} € / personne',
                          style: titleStyle),
                      const SizedBox(height: 8),
                      for (final (label, icon, pct, color) in parts)
                        _BudgetBar(
                          label: label,
                          icon: icon,
                          color: color,
                          amount: (d.budget * pct).round(),
                          value: _show ? pct : 0, // la barre se remplit
                        ),

                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Créer un voyage'),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Voyage vers ${d.name} créé !')),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int amount;
  final double value;

  const _BudgetBar({
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(label)),
              Text('$amount €', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
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
        ],
      ),
    );
  }
}