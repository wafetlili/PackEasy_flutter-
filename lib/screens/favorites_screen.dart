// ============================================================
// favorites_screen.dart
// Liste des destinations favorites (enregistrées dans Firestore
// pour les utilisateurs connectés).
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/destination_provider.dart';
import '../utils/l10n_ext.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/destination_card.dart';
import '../widgets/state_views.dart';
import '../widgets/travel_background.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.watch<DestinationProvider>();
    final list = p.favoriteDestinations;

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l.favorites),
        ),
        bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
        body: p.isLoading
            ? LoadingView(message: l.loading)
            : list.isEmpty
                ? EmptyView(
                    icon: Icons.favorite_border,
                    title: l.noFavorites,
                    subtitle: l.noFavoritesHint,
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, i) => DestinationCard(
                          key: ValueKey(list[i].id),
                          destination: list[i],
                          index: i,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
