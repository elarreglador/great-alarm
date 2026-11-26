import 'package:flutter/material.dart';

import '../../domain/entities/alarm.dart';
import '../../utils/app_colors.dart';
import 'alarm_tile.dart';
import 'digital_clock.dart';

/// Los dos tercios izquierdos: la lista de despertadores y su botón (+) .
class AlarmPanel extends StatelessWidget {
  final List<Alarm> alarms;
  final DateTime now;
  final ValueChanged<Alarm> onToggle;
  final ValueChanged<Alarm> onEdit;
  final ValueChanged<Alarm> onDelete;
  final VoidCallback onAdd;

  const AlarmPanel({
    super.key,
    required this.alarms,
    required this.now,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: DigitalClock(now: now),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              alarms.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Pulsa el botón (+) para programar tu primera alarma.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 15),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                      itemCount: alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = alarms[index];
                        return AlarmTile(
                          alarm: alarm,
                          now: now,
                          onEnabledChanged: (_) => onToggle(alarm),
                          onEdit: () => onEdit(alarm),
                          onDelete: () => onDelete(alarm),
                        );
                      },
                    ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingActionButton(
                  onPressed: onAdd,
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
