import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.flight_takeoff, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(trip['destination'] ?? 'Voyage', style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(trip['title'] ?? 'Sans titre', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Du ${trip['startDate']} au ${trip['endDate']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('${trip['price']} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
        ],
      ),
    );
  }
}