import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/time_formatter.dart';

/// Los dos relojes debajo del mapa: meridiano de Greenwich y hora local.
class ClockStrip extends StatelessWidget {
  final DateTime now;
  final String localLabel;

  const ClockStrip({
    super.key,
    required this.now,
    required this.localLabel,
  });

  @override
  Widget build(BuildContext context) {
    final gmt = now.toUtc();
    return Container(
      width: double.infinity,
      color: AppColors.panel,
      // Resguardo a la derecha para que el botón (+) no tape la hora local.
      padding: const EdgeInsets.fromLTRB(16, 10, 80, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ClockRow(
            time: TimezoneLabel.clock(gmt),
            place: 'GMT',
          ),
          const SizedBox(height: 4),
          _ClockRow(
            time: TimezoneLabel.clock(now),
            place: localLabel,
          ),
        ],
      ),
    );
  }
}

class _ClockRow extends StatelessWidget {
  final String time;
  final String place;

  const _ClockRow({required this.time, required this.place});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            place,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
