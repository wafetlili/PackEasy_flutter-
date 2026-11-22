// ============================================================
// trip_provider.dart
// Données de l'espace voyageur : voyages, dépenses et valise.
// Tout est enregistré dans Firestore, séparément pour chaque
// utilisateur connecté :
//   users/{uid}/trips      -> voyages
//   users/{uid}/expenses   -> dépenses (liées à un voyage)
//   users/{uid}/packing    -> objets de la valise
// Les listes se mettent à jour en temps réel (snapshots).
// ============================================================
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _uid;
  List<Trip> _trips = [];
  List<Expense> _expenses = [];
  List<PackItem> _items = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<User?>? _authSub;
  final List<StreamSubscription> _dataSubs = [];

  TripProvider() {
    // Chaque fois que l'utilisateur change, on recharge ses données
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _uid != null;

  // Raccourci vers users/{uid}/{nom}
  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(_uid).collection(name);

  // ------------------------------------------------------------
  // Écoute des données de l'utilisateur connecté
  // ------------------------------------------------------------
  void _onUserChanged(User? user) {
    for (final sub in _dataSubs) {
      sub.cancel();
    }
    _dataSubs.clear();

    _uid = user?.uid;
    _trips = [];
    _expenses = [];
    _items = [];
    _error = null;

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _dataSubs.add(_col('trips').snapshots().listen((snap) {
      _trips = snap.docs.map(Trip.fromDoc).toList();
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: _onError));

    _dataSubs.add(_col('expenses').snapshots().listen((snap) {
      _expenses = snap.docs.map(Expense.fromDoc).toList();
      notifyListeners();
    }, onError: _onError));

    _dataSubs.add(_col('packing').snapshots().listen((snap) {
      _items = snap.docs.map(PackItem.fromDoc).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    }, onError: _onError));
  }

  void _onError(Object e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }

  // Vérifie qu'un utilisateur est connecté avant d'écrire
  void _needLogin() {
    if (_uid == null) throw StateError('not-logged-in');
  }

  // Une écriture Firestore hors ligne reste en attente : on limite l'attente à 10 s
  Future<T> _write<T>(Future<T> action) =>
      action.timeout(const Duration(seconds: 10));

  // ---------- Voyages ----------
  List<Trip> get trips => _trips;

  List<Trip> get upcoming {
    final list = _trips.where((t) => !t.isPast).toList();
    list.sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  List<Trip> get history {
    final list = _trips.where((t) => t.isPast).toList();
    list.sort((a, b) => b.start.compareTo(a.start));
    return list;
  }

  Trip? get nextTrip => upcoming.isEmpty ? null : upcoming.first;
  int get tripCount => _trips.length;

  Trip? tripById(String id) {
    for (final t in _trips) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> addTrip(Trip trip) async {
    _needLogin();
    await _write(_col('trips').add(trip.toMap()));
  }

  // Supprime le voyage et toutes ses dépenses
  Future<void> removeTrip(String id) async {
    _needLogin();
    final batch = _db.batch();
    batch.delete(_col('trips').doc(id));
    for (final e in _expenses.where((e) => e.tripId == id)) {
      batch.delete(_col('expenses').doc(e.id));
    }
    await _write(batch.commit());
  }

  // ---------- Dépenses ----------
  List<Expense> expensesOf(String tripId) {
    final list = _expenses.where((e) => e.tripId == tripId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double spentOn(String tripId) => _expenses
      .where((e) => e.tripId == tripId)
      .fold(0.0, (sum, e) => sum + e.amount);

  double spentIn(String tripId, String category) => _expenses
      .where((e) => e.tripId == tripId && e.category == category)
      .fold(0.0, (sum, e) => sum + e.amount);

  Future<void> addExpense(Expense e) async {
    _needLogin();
    await _write(_col('expenses').add(e.toMap()));
  }

  Future<void> removeExpense(String id) async {
    _needLogin();
    await _write(_col('expenses').doc(id).delete());
  }

  // ---------- Valise ----------
  List<PackItem> get items => _items;
  int get packedCount => _items.where((i) => i.checked).length;

  bool hasItem(String name) =>
      _items.any((i) => i.name.toLowerCase() == name.toLowerCase());

  Future<void> addItem(String name) async {
    _needLogin();
    await _write(_col('packing').add({
      'name': name,
      'checked': false,
      'order': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  Future<void> toggleItem(PackItem item) async {
    _needLogin();
    await _write(_col('packing').doc(item.id).update({'checked': !item.checked}));
  }

  Future<void> removeItem(PackItem item) async {
    _needLogin();
    await _write(_col('packing').doc(item.id).delete());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    for (final sub in _dataSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}
