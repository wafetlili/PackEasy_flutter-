// ============================================================
// destination.dart
// Modèle d'une destination (stockée dans Firestore).
// ============================================================
class Destination {
  final String id, name, country, flag, continent, category, image, description;
  final int budget;
  final double rating;
  final String season, language, currency, temp;
  final List<String> highlights;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.flag,
    required this.continent,
    required this.category,
    required this.image,
    required this.description,
    required this.budget,
    required this.rating,
    required this.season,
    required this.language,
    required this.currency,
    required this.temp,
    required this.highlights,
  });

  // Crée une destination à partir d'un document Firestore.
  // Les valeurs manquantes reçoivent une valeur par défaut.
  factory Destination.fromMap(String id, Map<String, dynamic> data) {
    return Destination(
      id: id,
      name: data['name'] ?? '',
      country: data['country'] ?? '',
      flag: data['flag'] ?? '🌍',
      continent: data['continent'] ?? 'Monde',
      category: data['category'] ?? 'Ville',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      budget: ((data['budget'] ?? 0) as num).toInt(),
      rating: ((data['rating'] ?? 4.0) as num).toDouble(),
      season: data['season'] ?? '',
      language: data['language'] ?? '',
      currency: data['currency'] ?? '',
      temp: data['temp'] ?? '',
      highlights: List<String>.from(data['highlights'] ?? []),
    );
  }

  // Transforme la destination en Map pour l'enregistrer dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'flag': flag,
      'continent': continent,
      'category': category,
      'image': image,
      'description': description,
      'budget': budget,
      'rating': rating,
      'season': season,
      'language': language,
      'currency': currency,
      'temp': temp,
      'highlights': highlights,
    };
  }
}
