import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/models/land_geometry.dart';
import '../../data/repositories/alarm_repository.dart';
import '../../data/services/alarm_notification_scheduler.dart';
import '../../data/services/device_timezone_service.dart';
import '../../domain/entities/alarm.dart';
import '../../utils/app_colors.dart';
import '../widgets/add_alarm_sheet.dart';
import '../widgets/alarm_panel.dart';
import '../widgets/world_map_panel.dart';

/// Pantalla única, siempre horizontal: 2/3 alarmas, 1/3 mapa y relojes.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _clock = ValueNotifier<DateTime>(DateTime.now());
  final _repository = const AlarmRepository();
  final _scheduler = AlarmNotificationScheduler(
    FlutterLocalNotificationsPlugin(),
  );

  Timer? _ticker;
  List<Alarm> _alarms = const <Alarm>[];
  LandGeometry? _land;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _clock.value = DateTime.now(),
    );
    _bootstrap();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _clock.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final timezoneId = await const DeviceTimezoneService().read();
    await _scheduler.initialize(timezoneId);
    final land = await LandGeometry.load();

    final hasData = await _repository.hasStoredAlarms();
    final alarms = hasData ? await _repository.load() : _seedAlarms();
    if (!hasData) await _repository.save(alarms);
    await _scheduler.sync(alarms, DateTime.now());

    if (!mounted) return;
    setState(() {
      _land = land;
      _alarms = alarms;
      _ready = true;
    });
  }

  /// Dos ejemplos para que la pantalla tenga sentido la primera vez.
  List<Alarm> _seedAlarms() => <Alarm>[
        const Alarm(
          id: 1,
          label: 'cafetería con amigos',
          hour: 10,
          minute: 30,
          weekdays: <int>{1, 2, 3, 4, 5},
        ),
        const Alarm(
          id: 2,
          label: 'ir a dormir',
          hour: 22,
          minute: 45,
          weekdays: <int>{6, 7},
        ),
      ];

  Future<void> _persist() async {
    await _repository.save(_alarms);
    await _scheduler.sync(_alarms, DateTime.now());
  }

  Future<void> _addAlarm() async {
    final nextId = _alarms.fold<int>(
          0,
          (max, alarm) => alarm.id > max ? alarm.id : max,
        ) +
        1;
    final created = await AddAlarmSheet.show(context, nextId, _clock.value);
    if (created == null) return;
    setState(() => _alarms = <Alarm>[..._alarms, created]);
    await _persist();
  }

  Future<void> _editAlarm(Alarm alarm) async {
    final edited = await AddAlarmSheet.show(
      context,
      alarm.id,
      _clock.value,
      alarm: alarm,
    );
    if (edited == null) return;
    setState(() {
      _alarms = _alarms
          .map((a) => a.id == edited.id ? edited : a)
          .toList();
    });
    await _persist();
  }

  Future<void> _toggle(Alarm alarm) async {
    setState(() {
      _alarms = _alarms
          .map((a) => a.id == alarm.id ? a.copyWith(enabled: !a.enabled) : a)
          .toList();
    });
    await _persist();
  }

  Future<void> _delete(Alarm alarm) async {
    setState(() => _alarms = _alarms.where((a) => a.id != alarm.id).toList());
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.water,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ValueListenableBuilder<DateTime>(
                valueListenable: _clock,
                builder: (context, now, _) => AlarmPanel(
                  alarms: _alarms,
                  now: now,
                  onToggle: _toggle,
                  onEdit: _editAlarm,
                  onDelete: _delete,
                  onAdd: _ready ? _addAlarm : () {},
                ),
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.divider),
            Expanded(
              flex: 1,
              child: ValueListenableBuilder<DateTime>(
                valueListenable: _clock,
                builder: (context, now, _) => WorldMapPanel(
                  land: _land,
                  now: now,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
