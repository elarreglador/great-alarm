/// Tono pulsado disponible para una alarma. [hz] null significa «sin sonido».
class ToneOption {
  final int? hz;
  final String label;

  const ToneOption(this.hz, this.label);

  bool get isSilent => hz == null;
}

const List<ToneOption> toneOptions = <ToneOption>[
  ToneOption(440, 'Grave · 440 Hz'),
  ToneOption(550, '550 Hz'),
  ToneOption(700, 'Media · 700 Hz'),
  ToneOption(900, '900 Hz'),
  ToneOption(1200, 'Aguda · 1200 Hz'),
  ToneOption(1600, 'Muy aguda · 1600 Hz'),
];

const ToneOption silentTone = ToneOption(null, 'Sin sonido (solo vibración)');

/// Duración del pitido y de la pausa; el patrón se repite en bucle.
const Duration pulseOn = Duration(milliseconds: 400);
const Duration pulseOff = Duration(milliseconds: 400);
const Duration ringingLimit = Duration(minutes: 5);
