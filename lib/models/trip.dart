// ============================================================
// trip.dart
// Modèles de l'espace voyageur : voyage, dépense, objet de valise.
// Tout est enregistré dans Firestore sous users/{uid}/...
// ============================================================
import 'package:cloud_firestore/cloud_firestore.dart';

// Garde seulement le jour (sans l'heure) pour comparer les dates
DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

// ---------- Voyage ----------
class Trip {
  final String id;
  final String destination;
  final String flag;
  final DateTime start;
  final DateTime end;
  final int budget;

  Trip({
    required this.id,
    required this.destination,
    this.flag = '📍',
    required this.start,
    required this.end,
    required this.budget,
  });

  factory Trip.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Trip(
      id: doc.id,
      destination: d['destination'] ?? '',
      flag: d['flag'] ?? '📍',
      start: (d['start'] as Timestamp?)?.toDate() ?? DateTime.now(),
      end: (d['end'] as Timestamp?)?.toDate() ?? DateTime.now(),
      budget: ((d['budget'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'destination': destination,
        'flag': flag,
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'budget': budget,
      };

  int get days => end.difference(start).inDays + 1;
  int get daysLeft => _day(start).difference(_day(DateTime.now())).inDays;
  bool get isPast => _day(end).isBefore(_day(DateTime.now()));
}

// ---------- Dépense (liée à un voyage) ----------
class Expense {
  final String id;
  final String tripId;
  final String label;
  final String category; // transport, lodging, food, activities, other
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.tripId,
    required this.label,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory Expense.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return Expense(
      id: doc.id,
      tripId: d['tripId'] ?? '',
      label: d['label'] ?? '',
      category: d['category'] ?? 'other',
      amount: ((d['amount'] ?? 0) as num).toDouble(),
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'label': label,
        'category': category,
        'amount': amount,
        'date': Timestamp.fromDate(date),
      };
}

// ---------- Objet de la valise ----------
class PackItem {
  final String id;
  final String name;
  final bool checked;
  final int order; // sert à garder l'ordre d'ajout

  PackItem({
    required this.id,
    required this.name,
    this.checked = false,
    this.order = 0,
  });

  factory PackItem.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return PackItem(
      id: doc.id,
      name: d['name'] ?? '',
      checked: d['checked'] ?? false,
      order: ((d['order'] ?? 0) as num).toInt(),
    );
  }
}
