/// Punto geográfico mínimo, sin dependencias de paquetes de mapas.
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  @override
  String toString() => 'GeoPoint($latitude, $longitude)';
}
