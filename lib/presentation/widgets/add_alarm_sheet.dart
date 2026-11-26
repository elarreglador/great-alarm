import 'package:flutter/material.dart';

import '../../domain/entities/alarm.dart';
import '../../utils/app_colors.dart';

/// Formulario flotante del botón (+) y del lápiz de edición.
class AddAlarmSheet extends StatefulWidget {
  final int id;
  final DateTime now;
  final Alarm? alarm;

  const AddAlarmSheet({
    super.key,
    required this.id,
    required this.now,
    this.alarm,
  });

  static Future<Alarm?> show(
    BuildContext context,
    int id,
    DateTime now, {
    Alarm? alarm,
  }) {
    return showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddAlarmSheet(id: id, now: now, alarm: alarm),
    );
  }

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  final _labelController = TextEditingController(text: 'Nueva alarma');
  late TimeOfDay _time;
  late DateTime _date;
  late bool _repeats;
  final Set<int> _weekdays = <int>{};

  static const _dayLetters = <int, String>{
    1: 'L',
    2: 'M',
    3: 'X',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    _labelController.text = alarm?.label ?? 'Nueva alarma';
    _time = alarm == null
        ? TimeOfDay.fromDateTime(widget.now)
        : TimeOfDay(hour: alarm.hour, minute: alarm.minute);
    _date = alarm?.date ??
        DateTime(widget.now.year, widget.now.month, widget.now.day);
    _repeats = alarm?.isRepeating ?? true;
    _weekdays.addAll(alarm?.weekdays ?? <int>{1, 2, 3, 4, 5});
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.now.subtract(const Duration(days: 1)),
      lastDate: widget.now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_repeats && _weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige al menos un día de la semana')),
      );
      return;
    }
    final label = _labelController.text.trim().isEmpty
        ? 'Alarma'
        : _labelController.text.trim();
    Navigator.of(context).pop(
      Alarm(
        id: widget.id,
        label: label,
        hour: _time.hour,
        minute: _time.minute,
        weekdays: _repeats ? Set<int>.from(_weekdays) : const <int>{},
        date: _repeats ? null : _date,
        enabled: widget.alarm?.enabled ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.alarm == null ? 'Nueva alarma' : 'Editar alarma',
              style: const TextStyle(color: AppColors.text, fontSize: 20),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: AppColors.muted),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.divider),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time, color: AppColors.accent),
              title: Text(
                '${_two(_time.hour)}:${_two(_time.minute)}',
                style: const TextStyle(color: AppColors.text, fontSize: 18),
              ),
              trailing: const Text(
                'Cambiar',
                style: TextStyle(color: AppColors.muted),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _ModeButton(
                  label: 'Una sola vez',
                  selected: !_repeats,
                  onTap: () => setState(() => _repeats = false),
                ),
                const SizedBox(width: 8),
                _ModeButton(
                  label: 'Se repite',
                  selected: _repeats,
                  onTap: () => setState(() => _repeats = true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_repeats)
              Wrap(
                spacing: 8,
                children: _dayLetters.entries.map((entry) {
                  final selected = _weekdays.contains(entry.key);
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        _weekdays.add(entry.key);
                      } else {
                        _weekdays.remove(entry.key);
                      }
                    }),
                  );
                }).toList(),
              )
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: AppColors.accent),
                title: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(color: AppColors.text),
                ),
                trailing: const Text(
                  'Cambiar',
                  style: TextStyle(color: AppColors.muted),
                ),
                onTap: _pickDate,
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Guardar alarma'),
            ),
          ],
        ),
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.divider,
          ),
          foregroundColor: selected ? AppColors.accent : AppColors.muted,
        ),
        child: Text(label),
      ),
    );
  }
}
