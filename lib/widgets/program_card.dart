import 'package:flutter/material.dart';

class ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.card_travel, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  program['type'] ?? 'Séjour',
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            program['title'] ?? 'Sans titre',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${program['duration']}j', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text('${program['price']} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }
}