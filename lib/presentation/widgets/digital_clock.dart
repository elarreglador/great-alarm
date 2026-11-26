import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/time_formatter.dart';

/// Hora local con aspecto de reloj digital: monoespacio, tabular y con segundos.
class DigitalClock extends StatelessWidget {
  final DateTime now;

  const DigitalClock({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    return Text(
      TimezoneLabel.clock(now),
      style: const TextStyle(
        color: AppColors.accent,
        fontFamily: 'monospace',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }
}
