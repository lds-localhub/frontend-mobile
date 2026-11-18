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

final _currency = NumberFormat.currency(
  locale: 'pt_PT',
  symbol: '€',
  decimalDigits: 2,
);

/// Valor em euros com duas casas decimais (ex.: `350,00 €`).
///
/// Os espaços especiais do `intl` passam a espaços normais, para o texto ser
/// igual ao escrito nos testes e nos documentos.
String formatCurrency(double amount) =>
    _currency.format(amount).replaceAll(RegExp('[  ]'), ' ');

const _monthNames = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// Mês do relatório do Prestador (`AAAA-MM`) por extenso (ex.: `Julho 2026`).
///
/// Formatado a partir do texto, como as datas sem hora: o `intl` escreve o mês
/// com minúscula, e o protótipo tem maiúscula.
String formatMonth(String month) {
  final [year, number] = month.split('-');
  return '${_monthNames[int.parse(number) - 1]} $year';
}
