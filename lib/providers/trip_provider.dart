import 'package:flutter/material.dart';
import '../models/trip.dart';

class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  final List<Expense> _expenses = [];
  final List<PackItem> _items = [
    PackItem('Passeport'),
    PackItem('Chargeur de téléphone'),
    PackItem('Trousse de toilette'),
    PackItem('Vêtements'),
  ];

  // ---------- Voyages ----------
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

  void addTrip(Trip trip) {
    _trips.add(trip);
    notifyListeners();
  }

  void removeTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ---------- Dépenses ----------
  List<Expense> get expenses => _expenses.reversed.toList();
  double get totalSpent => _expenses.fold(0.0, (s, e) => s + e.amount);

  double spentIn(String category) => _expenses
      .where((e) => e.category == category)
      .fold(0.0, (s, e) => s + e.amount);

  void addExpense(Expense e) {
    _expenses.add(e);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ---------- Valise ----------
  List<PackItem> get items => _items;
  int get packedCount => _items.where((i) => i.checked).length;

  bool hasItem(String name) =>
      _items.any((i) => i.name.toLowerCase() == name.toLowerCase());

  void addItem(String name) {
    _items.add(PackItem(name));
    notifyListeners();
  }

  void toggleItem(PackItem item) {
    item.checked = !item.checked;
    notifyListeners();
  }

  void removeItem(PackItem item) {
    _items.remove(item);
    notifyListeners();
  }
}