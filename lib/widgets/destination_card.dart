import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import 'destination_image.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final int index;

  const DestinationCard({super.key, required this.destination, required this.index});

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.destination;
    final provider = context.watch<DestinationProvider>();
    final isFav = provider.isFavorite(d.id);

    // Apparition : fondu + glissement
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.index * 100),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            // Lance l'avion puis ouvre la page de détails
            onTap: () => Navigator.pushNamed(context, '/details', arguments: d),
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: _hover ? 22 : 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    DestinationImage(destination: d, height: 230),

                    // Dégradé + infos
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${d.flag} ${d.name}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  Text('${d.country} • ~${d.budget} €',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(' ${d.rating}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),

                    // Étiquette continent • catégorie
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${d.continent} • ${d.category}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),

                    // Bouton favori animé
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          provider.toggleFavorite(d.id);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isFav
                                ? '${d.name} retiré des favoris'
                                : '${d.name} ajouté aux favoris'),
                            duration: const Duration(seconds: 1),
                          ));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(isFav ? 12 : 8),
                          decoration: BoxDecoration(
                            color: isFav ? Colors.red : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.white : Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}