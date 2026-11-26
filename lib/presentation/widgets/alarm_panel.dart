import 'package:flutter/material.dart';

import '../../domain/entities/alarm.dart';
import 'alarm_tile.dart';
import '../../utils/app_colors.dart';

/// Los dos tercios izquierdos: la lista de despertadores.
class AlarmPanel extends StatelessWidget {
  final List<Alarm> alarms;
  final DateTime now;
  final ValueChanged<Alarm> onToggle;
  final ValueChanged<Alarm> onDelete;

  const AlarmPanel({
    super.key,
    required this.alarms,
    required this.now,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Mis alarmas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Expanded(
          child: alarms.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Pulsa el botón (+) para programar tu primera alarma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: alarms.length,
                  itemBuilder: (context, index) {
                    final alarm = alarms[index];
                    return AlarmTile(
                      alarm: alarm,
                      now: now,
                      onEnabledChanged: (_) => onToggle(alarm),
                      onDelete: () => onDelete(alarm),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
