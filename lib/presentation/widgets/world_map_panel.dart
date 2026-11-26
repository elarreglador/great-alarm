import 'package:flutter/material.dart';

import '../../data/models/land_geometry.dart';
import '../../domain/services/sun_terminator_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/time_formatter.dart';
import 'world_map_painter.dart';

/// Un tercio derecho de la pantalla: mapa día/noche sobre dos tercios de la
/// altura, reloj GMT en su esquina superior izquierda y hueco libre debajo.
class WorldMapPanel extends StatelessWidget {
  final LandGeometry? land;
  final DateTime now;

  const WorldMapPanel({
    super.key,
    required this.land,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final night = SunTerminatorService.nightPolygon(now.toUtc());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: land == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : Center(
                  // Proporción del mundo recortado al sur de Tierra del Fuego.
                  child: AspectRatio(
                    aspectRatio: WorldMapPainter.aspectRatio,
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: WorldMapPainter(land: land!, night: night),
                          size: Size.infinite,
                        ),
                        Positioned(
                          top: 6,
                          left: 8,
                          child: _GmtClock(
                            time: TimezoneLabel.shortClock(now.toUtc()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        // Mitad inferior reservada para un futuro widget.
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }
}

class _GmtClock extends StatelessWidget {
  final String time;

  const _GmtClock({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$time GMT',
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 13,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
