// ============================================================
// banner_ad_widget.dart
// Bannière publicitaire Google (identifiant de test).
// Rien n'est affiché sur le web ou tant que la pub n'est pas chargée.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.instance.isSupported) _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdService.instance.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        // La pub est prête : on l'affiche
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        // Échec : on libère la pub et on n'affiche rien
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          _ad = null;
          debugPrint('Bannière non chargée : ${error.message}');
        },
      ),
    );
    ad.load();
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();

    return Center(
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
