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
    final remaining = next?.difference(now) ?? Duration.zero;
    final hoursLeft = remaining <= Duration.zero
        ? 0
        // Cualquier tiempo positivo enciende al menos una celda.
        : ((remaining.inMinutes + 59) ~/ 60).clamp(1, 24);

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
                    child: _HourBar(
                      hoursLeft: hoursLeft,
                      blinkLast: remaining > Duration.zero &&
                          remaining < const Duration(minutes: 30),
                    ),
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
///
/// En el último cuadrado todavía encendido parpadea cuando quedan menos de
/// 30 minutos, para que el aviso se vea de reojo.
class _HourBar extends StatefulWidget {
  final int hoursLeft;
  final bool blinkLast;

  const _HourBar({required this.hoursLeft, required this.blinkLast});

  @override
  State<_HourBar> createState() => _HourBarState();
}

class _HourBarState extends State<_HourBar> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (widget.blinkLast) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _HourBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blinkLast == oldWidget.blinkLast) return;
    if (widget.blinkLast) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blinkingIndex = widget.hoursLeft - 1;
    return Semantics(
      label: 'Quedan ${widget.hoursLeft} horas como máximo en la barra',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            spacing: 2,
            children: List<Widget>.generate(24, (index) {
              final lit = index < widget.hoursLeft;
              final blinking =
                  widget.blinkLast && index == blinkingIndex && lit;
              final color = blinking
                  ? AppColors.progress.withValues(
                      alpha: 0.15 + 0.85 * _controller.value,
                    )
                  : lit
                      ? AppColors.progress
                      : AppColors.divider;
              return Expanded(
                child: Container(height: 8, color: color),
              );
            }),
          );
        },
      ),
    );
  }
}
