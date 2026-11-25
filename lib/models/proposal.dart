import 'tone.dart';

/// Estado de uma proposta, com o texto e a cor apresentados.
enum ProposalStatus {
  pending('PENDING', 'Pendente', Tone.pending),
  accepted('ACCEPTED', 'Aceite', Tone.success),
  declined('DECLINED', 'Recusada', Tone.danger),
  voided('VOID', 'Sem efeito', Tone.neutral);

  const ProposalStatus(this.apiValue, this.label, this.tone);

  final String apiValue;
  final String label;
  final Tone tone;

  static ProposalStatus fromJson(String value) =>
      values.firstWhere((s) => s.apiValue == value);
}
