import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/page.dart';

import 'app_lifecycle.dart';

/// Solicitações diretas recebidas pelo Prestador, da mais recente para a mais
/// antiga, com o filtro de estado e a página.
final directRequestsProvider = FutureProvider.autoDispose
    .family<Page<DirectRequestItem>, DirectRequestsParams>((ref, params) async {
      ref.watch(appResumedProvider);
      final query = toQueryString({
        'status': params.status?.apiValue,
        'page': params.page,
      });
      final json = await api('/direct-requests?$query');
      return Page.fromJson(
        json! as Map<String, dynamic>,
        DirectRequestItem.fromJson,
      );
    });

/// Detalhe de uma solicitação direta do Prestador.
final directRequestProvider = FutureProvider.autoDispose
    .family<DirectRequestDetail, int>((ref, directRequestId) async {
      ref.watch(appResumedProvider);
      final json = await api('/direct-requests/$directRequestId');
      return DirectRequestDetail.fromJson(json! as Map<String, dynamic>);
    });

/// Recusa uma solicitação direta e atualiza as solicitações (listas e
/// detalhe).
Future<void> declineDirectRequest(
  WidgetRef ref, {
  required int directRequestId,
}) async {
  await api('/direct-requests/$directRequestId/decline', method: 'POST');
  ref.invalidate(directRequestsProvider);
  ref.invalidate(directRequestProvider);
}
