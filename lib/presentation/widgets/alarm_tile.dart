import 'package:flutter/material.dart';

import '../../domain/entities/alarm.dart';
import '../../domain/services/alarm_calculator.dart';
import '../../utils/app_colors.dart';

/// Tarjeta compacta: dos renglones y controles en horizontal.
class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final DateTime now;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.now,
    required this.onEnabledChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final next = AlarmCalculator.nextOccurrence(alarm, now);
    final hoursLeft = (next?.difference(now).inHours ?? 0).clamp(0, 24);

    return Opacity(
      opacity: alarm.enabled ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alarm.label,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_two(alarm.hour)}:${_two(alarm.minute)}  '
                        '${alarm.daysLabel}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontFeatures: <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'sonará en ${AlarmCalculator.formatRemaining(next, now)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: _HourBar(hoursLeft: hoursLeft),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: alarm.enabled,
                  onChanged: onEnabledChanged,
                  activeThumbColor: AppColors.progress,
                ),
                IconButton(
                  tooltip: 'Editar alarma',
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  color: AppColors.muted,
                  onPressed: onEdit,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                ),
                IconButton(
                  tooltip: 'Borrar alarma',
                  icon: const Icon(Icons.delete_outline, size: 19),
                  color: AppColors.muted,
                  onPressed: onDelete,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
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

/// Barra de 24 celdas de una hora: se apagan de derecha a izquierda hasta que
/// la última se apaga y suena la alarma. Si falta más de un día, está llena.
class _HourBar extends StatelessWidget {
  final int hoursLeft;

  const _HourBar({required this.hoursLeft});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quedan $hoursLeft horas como máximo en la barra',
      child: Row(
        spacing: 2,
        children: List<Widget>.generate(24, (index) {
          final lit = index < hoursLeft;
          return Expanded(
            child: Container(
              height: 8,
              color: lit ? AppColors.progress : AppColors.divider,
            ),
          );
        }),
      ),
    );
  }
}
