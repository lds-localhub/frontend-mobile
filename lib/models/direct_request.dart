import 'tone.dart';

/// Estado de uma solicitação direta, com o texto e a cor apresentados.
enum DirectRequestStatus {
  pending('PENDING', 'Pendente', Tone.pending),
  proposalSubmitted('PROPOSAL_SUBMITTED', 'Proposta apresentada', Tone.success),
  declined('DECLINED', 'Recusada', Tone.danger),
  voided('VOID', 'Sem efeito', Tone.neutral);

  const DirectRequestStatus(this.apiValue, this.label, this.tone);

  final String apiValue;
  final String label;
  final Tone tone;

  static DirectRequestStatus fromJson(String value) =>
      values.firstWhere((s) => s.apiValue == value);
}
