// ============================================================
// ad_service.dart
// Publicités Google (google_mobile_ads) : bannière + interstitielle.
// ATTENTION : uniquement les identifiants de TEST fournis par Google.
// Les publicités fonctionnent sur Android et iOS (pas sur le web).
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // Identifiants de TEST de Google
  static const _bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _bannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _interstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _interstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  // Vrai seulement sur Android et iOS
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String get bannerId =>
      defaultTargetPlatform == TargetPlatform.android ? _bannerAndroid : _bannerIos;

  String get _interstitialId => defaultTargetPlatform == TargetPlatform.android
      ? _interstitialAndroid
      : _interstitialIos;

  InterstitialAd? _interstitial;

  // Démarre le SDK puis prépare une publicité interstitielle
  Future<void> init() async {
    if (!isSupported) return;
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  // Charge une publicité interstitielle en avance
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitielle non chargée : ${error.message}');
          _interstitial = null;
        },
      ),
    );
  }

  // Affiche la publicité interstitielle (si elle est prête)
  void showInterstitial() {
    final ad = _interstitial;
    if (ad == null) {
      if (isSupported) _loadInterstitial();
      return;
    }
    _interstitial = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      // Après fermeture ou erreur : on libère la pub et on en charge une nouvelle
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }
}
