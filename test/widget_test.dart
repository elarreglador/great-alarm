import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:great_alarm/domain/entities/alarm.dart';
import 'package:great_alarm/presentation/widgets/alarm_tile.dart';

void main() {
  testWidgets('la tarjeta muestra hora, días y cuenta atrás', (tester) async {
    final now = DateTime(2026, 2, 18, 19, 52, 8);
    final alarm = Alarm(
      id: 1,
      label: 'cafetería con amigos',
      hour: 10,
      minute: 30,
      weekdays: const <int>{1, 2, 3, 4, 5},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlarmTile(
            alarm: alarm,
            now: now,
            onEnabledChanged: (_) {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('cafetería con amigos'), findsOneWidget);
    expect(find.textContaining('10:30  L,M,X,J,V'), findsOneWidget);
    expect(find.text('sonará en 14 h 37 m'), findsOneWidget);
  });
}
