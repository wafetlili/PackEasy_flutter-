DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

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

  int get days => end.difference(start).inDays + 1;
  int get daysLeft => _day(start).difference(_day(DateTime.now())).inDays;
  bool get isPast => _day(end).isBefore(_day(DateTime.now()));
}

class Expense {
  final String id;
  final String label;
  final String category;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.label,
    required this.category,
    required this.amount,
    required this.date,
  });
}

class PackItem {
  String name;
  bool checked;
  PackItem(this.name, {this.checked = false});
}