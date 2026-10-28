import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DestinationService _service = DestinationService();

  List<Destination> _staticDestinations = [];
  List<Destination> _firestoreDestinations = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  int get total => filtered.length;

  final continents = ['Tous', 'Afrique', 'Europe', 'Asie', 'Amérique', 'Océanie'];
  String category = 'Tous';
  String continent = 'Tous';
  String query = '';
  final Set<String> _favorites = {};

  DestinationProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _staticDestinations = await _service.fetchDestinations();
    _isLoading = false;
    notifyListeners();

    _firestore.collection('destinations').snapshots().listen((snapshot) {
      _firestoreDestinations = snapshot.docs.map((doc) {
        final data = doc.data();
        return Destination(
          id: doc.id,
          name: data['name'] ?? 'Sans nom',
          country: data['country'] ?? 'Inconnu',
          flag: data['flag'] ?? '🌍',
          continent: data['continent'] ?? 'Monde',
          category: data['category'] ?? 'Ville',
          image: data['image'] ?? 'https://via.placeholder.com/400',
          description: data['description'] ?? 'Aucune description.',
          budget: data['budget'] ?? 0,
          rating: (data['rating'] ?? 4.0).toDouble(),
          season: data['season'] ?? 'Toute l\'année',
          language: data['language'] ?? 'Local',
          currency: data['currency'] ?? 'EUR',
          temp: data['temp'] ?? '25°C',
          highlights: List<String>.from(data['highlights'] ?? []),
        );
      }).toList();
      notifyListeners();
    });
  }

  List<Destination> get filtered {
    final all = [..._staticDestinations, ..._firestoreDestinations];
    final uniqueMap = <String, Destination>{};
    for (final dest in all) {
      final key = dest.name.toLowerCase().trim();
      if (!uniqueMap.containsKey(key)) {
        uniqueMap[key] = dest;
      }
    }
    
    final text = query.toLowerCase();
    return uniqueMap.values.where((d) {
      final okCategory = category == 'Tous' || d.category == category;
      final okContinent = continent == 'Tous' || d.continent == continent;
      final okQuery = d.name.toLowerCase().contains(text) || d.country.toLowerCase().contains(text);
      return okCategory && okContinent && okQuery;
    }).toList();
  }

  List<Destination> get trending {
    final list = [...filtered];
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(6).toList();
  }

  void setCategory(String value) { category = value; notifyListeners(); }
  void setContinent(String value) { continent = value; notifyListeners(); }
  void setQuery(String value) { query = value; notifyListeners(); }
  bool isFavorite(String id) => _favorites.contains(id);
  void toggleFavorite(String id) {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();
  }
}