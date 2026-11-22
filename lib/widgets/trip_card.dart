// ============================================================
// trip_card.dart
// Carte d'un voyage proposé par l'admin (collection "trips").
// ============================================================
import 'package:flutter/material.dart';
import '../utils/l10n_ext.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Container(
      width: 220,
      margin: const EdgeInsetsDirectional.only(end: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.flight_takeoff, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trip['destination'] ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trip['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            l.tripFromTo('${trip['startDate'] ?? ''}', '${trip['endDate'] ?? ''}'),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text('${trip['price'] ?? 0} €',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
        ],
      ),
    );
  }
}
