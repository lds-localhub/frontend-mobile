import 'tone.dart';

/// Estado de um serviço, com o texto e a cor apresentados.
enum ServiceStatus {
  open('OPEN', 'Aberto', Tone.info),
  assigned('ASSIGNED', 'Atribuído', Tone.warning),
  completed('COMPLETED', 'Realizado', Tone.success),
  cancelled('CANCELLED', 'Cancelado', Tone.neutral);

  const ServiceStatus(this.apiValue, this.label, this.tone);

  final String apiValue;
  final String label;
  final Tone tone;

  static ServiceStatus fromJson(String value) =>
      values.firstWhere((s) => s.apiValue == value);
}
