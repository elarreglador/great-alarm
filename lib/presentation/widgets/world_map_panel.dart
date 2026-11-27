import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/land_geometry.dart';
import '../../domain/entities/ringing_state.dart';
import '../../domain/services/sun_terminator_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/time_formatter.dart';
import 'ringing_panel.dart';
import 'world_map_painter.dart';

/// Un tercio derecho de la pantalla: carrusel de 10 s entre el mapamundi y el
/// consejo de volumen. La mitad inferior sigue mostrando la alarma en curso.
class WorldMapPanel extends StatefulWidget {
  static const String advice =
      'Consejo: puedes silenciar las alarmas con los botones de volumen sin desbloquear el movil';

  final LandGeometry? land;
  final DateTime now;
  final RingingState? ringing;
  final VoidCallback onSilence;

  const WorldMapPanel({
    super.key,
    required this.land,
    required this.now,
    required this.ringing,
    required this.onSilence,
  });

  @override
  State<WorldMapPanel> createState() => _WorldMapPanelState();
}

class _WorldMapPanelState extends State<WorldMapPanel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _advance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (!mounted || !_controller.hasClients) return;
    final next = (_page + 1) % 2;
    _page = next;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: PageView(
            controller: _controller,
            onPageChanged: (page) => _page = page,
            children: <Widget>[_mapPage(), const _AdvicePage()],
          ),
        ),
        Expanded(
          flex: 1,
          child: widget.ringing == null
              ? const SizedBox.shrink()
              : RingingPanel(
                  ringing: widget.ringing!,
                  now: widget.now,
                  onSilence: widget.onSilence,
                ),
        ),
      ],
    );
  }

  Widget _mapPage() {
    final night = SunTerminatorService.nightPolygon(widget.now.toUtc());
    return widget.land == null
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
                    painter: WorldMapPainter(land: widget.land!, night: night),
                    size: Size.infinite,
                  ),
                  Positioned(
                    top: 6,
                    left: 8,
                    child: _GmtClock(
                      time: TimezoneLabel.shortClock(widget.now.toUtc()),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

/// Segunda página del carrusel: recuerda cómo silenciar sin desbloquear.
class _AdvicePage extends StatelessWidget {
  const _AdvicePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.volume_off, color: AppColors.accent, size: 26),
            SizedBox(height: 8),
            Text(
              WorldMapPanel.advice,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
