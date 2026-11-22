// ============================================================
// destination_details_screen.dart
// Détails d'une destination (reçue en argument de la route).
//  - image partagée avec la liste (Hero)
//  - météo en direct via une API REST (FutureBuilder)
//  - bouton favori
//  - création d'un voyage enregistré dans Firestore, avec
//    notification de confirmation et publicité interstitielle
// ============================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/destination.dart';
import '../models/trip.dart';
import '../providers/destination_provider.dart';
import '../providers/trip_provider.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../utils/app_navigator.dart';
import '../utils/l10n_ext.dart';
import '../utils/labels.dart';
import '../utils/ui.dart';
import '../widgets/destination_image.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key});

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  bool _show = false; // déclenche les animations d'apparition
  bool _saving = false; // création du voyage en cours
  Future<WeatherInfo>? _weather;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _show = true);
    });
  }

  // La destination est lue ici car ModalRoute n'est pas disponible dans initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _weather ??= _loadWeather(_destination);
  }

  Destination get _destination =>
      ModalRoute.of(context)!.settings.arguments as Destination;

  Future<WeatherInfo> _loadWeather(Destination d) =>
      ApiService().fetchWeather([d.name, d.country]);

  // Nouvel essai de la météo (bouton "Réessayer")
  void _reloadWeather() {
    setState(() => _weather = _loadWeather(_destination));
  }

  // Favori : ajoute ou retire la destination
  Future<void> _toggleFavorite(Destination d) async {
    final l = context.l10n;
    try {
      final isNow = await context.read<DestinationProvider>().toggleFavorite(d.id);
      if (!mounted) return;
      showMessage(context,
          isNow ? l.addedToFavorites(d.name) : l.removedFromFavorites(d.name));
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    }
  }

  // Crée un voyage vers cette destination
  Future<void> _createTrip(Destination d) async {
    final l = context.l10n;

    // Il faut être connecté pour enregistrer un voyage
    if (FirebaseAuth.instance.currentUser == null) {
      showMessage(
        context,
        l.loginRequired,
        action: SnackBarAction(
          label: l.login,
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      );
      return;
    }

    // Choix des dates
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (range == null || !mounted) return;

    setState(() => _saving = true);
    try {
      await context.read<TripProvider>().addTrip(Trip(
            id: '',
            destination: d.name,
            flag: d.flag,
            start: range.start,
            end: range.end,
            budget: d.budget,
          ));
      if (!mounted) return;

      // Notification de confirmation : un appui ouvre "Mes voyages"
      NotificationService().showNotification(
        title: l.reservationConfirmed,
        body: l.reservationBody(d.name),
        payload: 'reservation',
      );

      showMessage(
        context,
        l.tripCreated(d.name),
        action: SnackBarAction(label: l.view, onPressed: () => openScreen('reservation')),
      );

      // Publicité interstitielle après l'action réussie
      AdService.instance.showInterstitial();
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(l, e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _destination;
    final l = context.l10n;
    final isFav = context.watch<DestinationProvider>().isFavorite(d.id);
    const titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

    // Répartition indicative du budget (pourcentage par catégorie)
    final parts = [
      ('transport', Icons.flight, 0.35, Colors.blue),
      ('lodging', Icons.hotel, 0.30, Colors.purple),
      ('food', Icons.restaurant, 0.20, Colors.orange),
      ('activities', Icons.local_activity, 0.15, Colors.green),
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
                onPressed: () => _toggleFavorite(d),
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
                  // Même tag que la carte : l'image "voyage" jusqu'ici
                  Hero(
                    tag: 'destination-${d.id}',
                    child: DestinationImage(destination: d, height: 320),
                  ),
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
                          Chip(label: Text(continentLabel(l, d.continent))),
                          Chip(label: Text(categoryLabel(l, d.category))),
                          Chip(label: Text('${d.rating} ★')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(d.description, style: const TextStyle(fontSize: 16)),

                      // Météo en direct (API REST)
                      const SizedBox(height: 24),
                      Text(l.liveWeather, style: titleStyle),
                      const SizedBox(height: 12),
                      _buildWeather(l),

                      // Infos pratiques
                      const SizedBox(height: 24),
                      Text(l.practicalInfo, style: titleStyle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _InfoTile(Icons.wb_sunny, l.bestSeason, d.season),
                          _InfoTile(Icons.thermostat, l.avgTemp, d.temp),
                          _InfoTile(Icons.translate, l.languages, d.language),
                          _InfoTile(Icons.payments, l.currency, d.currency),
                        ],
                      ),

                      // Points forts (apparition animée avec AnimatedOpacity)
                      if (d.highlights.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(l.mustSee, style: titleStyle),
                        const SizedBox(height: 8),
                        for (int i = 0; i < d.highlights.length; i++)
                          AnimatedOpacity(
                            opacity: _show ? 1 : 0,
                            duration: Duration(milliseconds: 500 + i * 250),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Text('${i + 1}')),
                                title: Text(d.highlights[i]),
                              ),
                            ),
                          ),
                      ],

                      // Budget
                      const SizedBox(height: 24),
                      Text(l.budgetIndicative(d.budget), style: titleStyle),
                      const SizedBox(height: 8),
                      for (final (code, icon, pct, color) in parts)
                        _BudgetBar(
                          label: expenseLabel(l, code),
                          icon: icon,
                          color: color,
                          amount: (d.budget * pct).round(),
                          value: _show ? pct : 0,
                        ),

                      const SizedBox(height: 28),

                      // Création d'un voyage (Firestore + notification + publicité)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: _saving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.add_location_alt),
                          label: Text(l.createTrip),
                          onPressed: _saving ? null : () => _createTrip(d),
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

  // FutureBuilder : chargement, erreur ou météo
  Widget _buildWeather(AppLocalizations l) {
    return FutureBuilder<WeatherInfo>(
      future: _weather,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Row(
            children: [
              const Icon(Icons.cloud_off),
              const SizedBox(width: 8),
              Expanded(child: Text(l.weatherUnavailable)),
              TextButton(onPressed: _reloadWeather, child: Text(l.retry)),
            ],
          );
        }

        final w = snapshot.data!;
        return Card(
          child: ListTile(
            leading: Icon(_weatherIcon(w.code), size: 40, color: Colors.orange),
            title: Text('${w.temperature.round()}°C  -  ${_weatherText(l, w.code)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l.wind(w.windSpeed.round().toString())),
          ),
        );
      },
    );
  }

  // Code météo (norme WMO) -> texte
  String _weatherText(AppLocalizations l, int code) {
    if (code == 0) return l.weatherClear;
    if (code == 45 || code == 48) return l.weatherFog;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return l.weatherRain;
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) return l.weatherSnow;
    if (code >= 95) return l.weatherStorm;
    return l.weatherCloudy;
  }

  // Code météo -> icône
  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code == 45 || code == 48) return Icons.blur_on;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return Icons.water_drop;
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) return Icons.ac_unit;
    if (code >= 95) return Icons.flash_on;
    return Icons.cloud;
  }
}

// Petite tuile d'information (saison, langue, etc.)
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
          Text(value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Barre de budget animée
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
