// ============================================================
// program_card.dart
// Carte d'un programme (document de la collection "programs").
// ============================================================
import 'package:flutter/material.dart';
import '../utils/labels.dart';
import '../utils/l10n_ext.dart';

class ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final type = programTypeLabel(l, program['type'] ?? 'Autre');
    final duration = ((program['duration'] ?? 0) as num).toInt();

    return Container(
      width: 200,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.card_travel, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  type,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            program['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(l.durationShort(duration),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Text('${program['price'] ?? 0} €',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }
}
