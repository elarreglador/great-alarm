import 'package:flutter/material.dart';

import '../../data/models/land_geometry.dart';
import '../../domain/services/sun_terminator_service.dart';
import '../../utils/app_colors.dart';
import 'clock_strip.dart';
import 'world_map_painter.dart';

/// Un tercio derecho de la pantalla: mapa día/noche y los dos relojes.
class WorldMapPanel extends StatelessWidget {
  final LandGeometry? land;
  final DateTime now;
  final String localLabel;

  const WorldMapPanel({
    super.key,
    required this.land,
    required this.now,
    required this.localLabel,
  });

  @override
  Widget build(BuildContext context) {
    final night = SunTerminatorService.nightPolygon(now.toUtc());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: land == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : Center(
                  // Proporción del mundo recortado al sur de Tierra del Fuego.
                  // Sin esto, un panel alto y estrecho estira los continentes.
                  child: AspectRatio(
                    aspectRatio: WorldMapPainter.aspectRatio,
                    child: CustomPaint(
                      painter: WorldMapPainter(land: land!, night: night),
                      size: Size.infinite,
                    ),
                  ),
                ),
        ),
        ClockStrip(now: now, localLabel: localLabel),
      ],
    );
  }
}
