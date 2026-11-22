// ============================================================
// destination_card.dart
// Carte d'une destination dans la liste de l'accueil.
// Animations : apparition, zoom au survol, bouton favori animé
// (AnimatedContainer) et image partagée avec la page de détails (Hero).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import '../utils/labels.dart';
import '../utils/l10n_ext.dart';
import '../utils/ui.dart';
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

  // Ajoute ou retire des favoris, puis affiche un message
  Future<void> _toggleFavorite() async {
    final d = widget.destination;
    final l = context.l10n;
    try {
      final isNowFavorite = await context.read<DestinationProvider>().toggleFavorite(d.id);
      if (!mounted) return;
      showMessage(
        context,
        isNowFavorite ? l.addedToFavorites(d.name) : l.removedFromFavorites(d.name),
      );
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.destination;
    final l = context.l10n;
    final isFav = context.watch<DestinationProvider>().isFavorite(d.id);

    // Apparition : fondu + glissement
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      // Les cartes au-delà de la 7e apparaissent toutes au même rythme
      duration: Duration(
          milliseconds: 400 + (widget.index > 6 ? 6 : widget.index) * 100),
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
            // Ouvre la page de détails en lui passant la destination en argument
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
                    // Hero : l'image "voyage" vers la page de détails
                    Hero(
                      tag: 'destination-${d.id}',
                      child: DestinationImage(destination: d, height: 230),
                    ),

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
                    PositionedDirectional(
                      top: 14,
                      start: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                            '${continentLabel(l, d.continent)} • ${categoryLabel(l, d.category)}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),

                    // Bouton favori animé
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
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
