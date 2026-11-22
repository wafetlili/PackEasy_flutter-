// ============================================================
// api_service.dart
// Appels à des API REST publiques avec le package http :
//  - Open-Meteo : météo en direct d'une ville
//  - ExchangeRate API : taux de change des devises
// ============================================================
import 'dart:convert';
import 'package:http/http.dart' as http;

// Erreur renvoyée quand l'API ne répond pas correctement
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

// Météo actuelle
class WeatherInfo {
  final double temperature; // en degrés Celsius
  final double windSpeed; // en km/h
  final int code; // code météo WMO (0 = ciel dégagé, etc.)

  WeatherInfo({
    required this.temperature,
    required this.windSpeed,
    required this.code,
  });
}

// Taux de change d'une devise de base
class ExchangeRates {
  final String base;
  final Map<String, double> rates;
  final DateTime updatedAt;

  ExchangeRates({
    required this.base,
    required this.rates,
    required this.updatedAt,
  });
}

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  // Récupère un JSON depuis une URL (erreur si le serveur ne répond pas 200)
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiException('HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ------------------------------------------------------------
  // Météo d'une ville.
  // Étape 1 : on cherche les coordonnées de la ville (géocodage).
  // Étape 2 : on demande la météo actuelle à ces coordonnées.
  // [names] : liste de noms à essayer (ville, puis pays)
  // ------------------------------------------------------------
  Future<WeatherInfo> fetchWeather(List<String> names) async {
    double? latitude;
    double? longitude;

    for (final name in names) {
      if (name.trim().isEmpty) continue;
      final geo = await _getJson(Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {'name': name, 'count': '1'},
      ));
      final results = geo['results'] as List?;
      if (results != null && results.isNotEmpty) {
        latitude = (results.first['latitude'] as num).toDouble();
        longitude = (results.first['longitude'] as num).toDouble();
        break;
      }
    }
    if (latitude == null || longitude == null) {
      throw ApiException('city-not-found');
    }

    final data = await _getJson(Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current': 'temperature_2m,wind_speed_10m,weather_code',
      },
    ));
    final current = data['current'] as Map<String, dynamic>;
    return WeatherInfo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      code: (current['weather_code'] as num).toInt(),
    );
  }

  // ------------------------------------------------------------
  // Taux de change pour une devise de base (ex : EUR)
  // ------------------------------------------------------------
  Future<ExchangeRates> fetchRates(String base) async {
    final data = await _getJson(Uri.https('open.er-api.com', '/v6/latest/$base'));
    if (data['result'] != 'success') {
      throw ApiException('rates-error');
    }
    final raw = data['rates'] as Map<String, dynamic>;
    final updatedSeconds = (data['time_last_update_unix'] as num?)?.toInt();
    return ExchangeRates(
      base: base,
      rates: raw.map((key, value) => MapEntry(key, (value as num).toDouble())),
      updatedAt: updatedSeconds == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(updatedSeconds * 1000),
    );
  }
}
