import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/proposal.dart';

import 'direct_requests.dart';

/// Apresenta a proposta do Prestador a um serviço e atualiza as
/// solicitações diretas, que passam a «Proposta apresentada».
Future<void> submitProposal(
  WidgetRef ref, {
  required int serviceId,
  required ProposalInput body,
}) async {
  await api(
    '/services/$serviceId/proposals',
    method: 'POST',
    body: body.toJson(),
  );
  ref.invalidate(directRequestsProvider);
  ref.invalidate(directRequestProvider);
}
