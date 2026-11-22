// ============================================================
// destination_provider.dart
// Gère la liste des destinations (Firestore en temps réel), les
// filtres (continent, catégorie, recherche) et les favoris.
// Les favoris des utilisateurs connectés sont enregistrés dans
// Firestore : users/{uid}/favorites/{idDestination}
// ============================================================
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/destination_service.dart';

class DestinationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DestinationService _service = DestinationService();

  List<Destination> _remote = []; // destinations venant de Firestore
  bool _isLoading = true;
  String? _error;

  // Filtres
  final continents = ['Tous', 'Afrique', 'Europe', 'Asie', 'Amérique', 'Océanie'];
  String category = 'Tous';
  String continent = 'Tous';
  String query = '';

  // Identifiants des destinations favorites
  final Set<String> _favorites = {};
  String? _uid;

  StreamSubscription? _destSub;
  StreamSubscription? _favSub;
  StreamSubscription<User?>? _authSub;

  DestinationProvider() {
    _listenDestinations();
    // Quand l'utilisateur se connecte ou se déconnecte, on recharge ses favoris
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Liste complète : Firestore, ou les exemples si Firestore est vide
  List<Destination> get all {
    if (_remote.isNotEmpty) return _remote;
    if (_isLoading) return [];
    return _service.getStaticDestinations();
  }

  // ---------- Destinations en temps réel ----------
  void _listenDestinations() {
    _destSub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _destSub = _firestore.collection('destinations').snapshots().listen(
      (snapshot) {
        _remote = snapshot.docs
            .map((doc) => Destination.fromMap(doc.id, doc.data()))
            .toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object e) {
        // En cas d'erreur, on garde les destinations d'exemple
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // Bouton "Réessayer"
  void retry() => _listenDestinations();

  // ---------- Filtres ----------
  List<Destination> get filtered {
    final text = query.toLowerCase().trim();
    return all.where((d) {
      final okCategory = category == 'Tous' || d.category == category;
      final okContinent = continent == 'Tous' || d.continent == continent;
      final okQuery = d.name.toLowerCase().contains(text) ||
          d.country.toLowerCase().contains(text);
      return okCategory && okContinent && okQuery;
    }).toList();
  }

  int get total => filtered.length;

  List<Destination> get trending {
    final list = [...filtered];
    list.sort((a, b) => b.rating.compareTo(a.rating));
    return list.take(6).toList();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setContinent(String value) {
    continent = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  // ---------- Favoris ----------
  bool isFavorite(String id) => _favorites.contains(id);

  List<Destination> get favoriteDestinations =>
      all.where((d) => _favorites.contains(d.id)).toList();

  void _onUserChanged(User? user) {
    _favSub?.cancel();
    _favSub = null;
    _uid = user?.uid;
    _favorites.clear();

    if (user != null) {
      _favSub = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .snapshots()
          .listen((snapshot) {
        _favorites
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));
        notifyListeners();
      }, onError: (Object e) => debugPrint('Favoris : $e'));
    }
    notifyListeners();
  }

  // Ajoute ou retire un favori. Renvoie true si la destination est maintenant favorite.
  Future<bool> toggleFavorite(String id) async {
    final wasFavorite = _favorites.contains(id);

    // Mise à jour immédiate de l'écran
    wasFavorite ? _favorites.remove(id) : _favorites.add(id);
    notifyListeners();

    // Invité (non connecté) : le favori reste seulement en mémoire
    final uid = _uid;
    if (uid == null) return !wasFavorite;

    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id);
    try {
      if (wasFavorite) {
        await doc.delete();
      } else {
        await doc.set({'addedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      // Échec : on annule le changement
      wasFavorite ? _favorites.add(id) : _favorites.remove(id);
      notifyListeners();
      rethrow;
    }
    return !wasFavorite;
  }

  @override
  void dispose() {
    _destSub?.cancel();
    _favSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
