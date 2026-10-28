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
}