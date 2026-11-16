import 'package:intl/intl.dart';

/// Data de um instante UTC da API na hora local (ex.: `28/09/2026`).
String formatDate(String instant) =>
    DateFormat('dd/MM/yyyy', 'pt_PT').format(DateTime.parse(instant).toLocal());

/// Data e hora de um instante UTC da API na hora local
/// (ex.: `28/09/2026, 11:00`).
String formatDateTime(String instant) => DateFormat(
  'dd/MM/yyyy, HH:mm',
  'pt_PT',
).format(DateTime.parse(instant).toLocal());

/// Data sem hora da API (`AAAA-MM-DD`) como `dd/mm/aaaa`.
///
/// Formatada a partir do texto, sem passar por `DateTime`, para não mudar de
/// dia com o fuso horário.
String formatDay(String day) {
  final [year, month, date] = day.split('-');
  return '$date/$month/$year';
}
