import 'package:flutter/material.dart';

import '../../domain/entities/ringing_state.dart';
import '../../utils/app_colors.dart';

/// Ocupa el hueco inferior del panel derecho solo mientras suena una alarma.
class RingingPanel extends StatelessWidget {
  final RingingState ringing;
  final DateTime now;
  final VoidCallback onSilence;

  const RingingPanel({
    super.key,
    required this.ringing,
    required this.now,
    required this.onSilence,
  });

  @override
  Widget build(BuildContext context) {
    final left = ringing.remaining(now);
    final seconds = left.inSeconds;
    final clock =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';

    return Container(
      // Sin margen horizontal: ocupa exactamente el ancho del mapa.
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Alarma en curso',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            ringing.label,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'se apaga en $clock',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onSilence,
            icon: const Icon(Icons.volume_off),
            label: const Text('Silenciar'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
