import 'package:flutter/material.dart';

import '../../domain/entities/alarm.dart';
import '../../domain/services/alarm_calculator.dart';
import '../../utils/app_colors.dart';

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final DateTime now;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.now,
    required this.onEnabledChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final next = AlarmCalculator.nextOccurrence(alarm, now);
    final remaining = AlarmCalculator.remainingFraction(next, now);
    final countdown = AlarmCalculator.formatRemaining(next, now);

    return Opacity(
      opacity: alarm.enabled ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.label,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_two(alarm.hour)}:${_two(alarm.minute)}  '
                    '${alarm.daysLabel}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontFeatures: <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'sonará en $countdown',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _CountdownBar(fraction: remaining),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: alarm.enabled,
                  onChanged: onEnabledChanged,
                  activeThumbColor: AppColors.progress,
                ),
                IconButton(
                  tooltip: 'Borrar alarma',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.muted,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _CountdownBar extends StatelessWidget {
  final double fraction;

  const _CountdownBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 8,
        color: AppColors.divider,
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: fraction,
          child: Container(color: AppColors.progress),
        ),
      ),
    );
  }
}
