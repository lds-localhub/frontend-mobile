import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/models/service.dart';

import 'app_lifecycle.dart';
import 'direct_requests.dart';
import 'profiles.dart';
import 'reports.dart';
import 'search.dart';

/// Serviços do Cliente autenticado, do mais recente para o mais antigo, com o
/// filtro de estado e a página.
final servicesProvider = FutureProvider.autoDispose
    .family<Page<ServiceItem>, ServicesParams>((ref, params) async {
      ref.watch(appResumedProvider);
      final query = toQueryString({
        'status': params.status?.apiValue,
        'page': params.page,
      });
      final json = await api('/services?$query');
      return Page.fromJson(json! as Map<String, dynamic>, ServiceItem.fromJson);
    });

/// Detalhe de um serviço do Cliente autenticado.
final serviceProvider = FutureProvider.autoDispose.family<ServiceDetail, int>((
  ref,
  serviceId,
) async {
  ref.watch(appResumedProvider);
  final json = await api('/services/$serviceId');
  return ServiceDetail.fromJson(json! as Map<String, dynamic>);
});

/// Cria um serviço e devolve-o, para abrir o seu detalhe.
Future<ServiceDetail> createService(
  WidgetRef ref, {
  required CreateServiceInput body,
}) async {
  final json = await api('/services', method: 'POST', body: body.toJson());
  ref.invalidate(servicesProvider);
  return ServiceDetail.fromJson(json! as Map<String, dynamic>);
}

/// O estado dos serviços e das propostas, na lista e no detalhe.
void refreshServices(WidgetRef ref) {
  ref.invalidate(servicesProvider);
  ref.invalidate(serviceProvider);
}

/// Os serviços e os relatórios, que só contam os serviços que chegaram a
/// atribuídos ou a realizados.
void refreshServicesAndReports(WidgetRef ref) {
  refreshServices(ref);
  ref.invalidate(clientReportProvider);
  ref.invalidate(providerReportProvider);
}

/// Aceita uma proposta: o serviço passa a atribuído.
Future<void> acceptProposal(WidgetRef ref, {required int proposalId}) async {
  await api('/proposals/$proposalId/accept', method: 'POST');
  refreshServicesAndReports(ref);
}

/// Recusa uma proposta: o serviço continua aberto.
Future<void> declineProposal(WidgetRef ref, {required int proposalId}) async {
  await api('/proposals/$proposalId/decline', method: 'POST');
  refreshServices(ref);
}

/// Marca um serviço atribuído como realizado.
Future<void> completeService(WidgetRef ref, {required int serviceId}) async {
  await api('/services/$serviceId/complete', method: 'POST');
  refreshServicesAndReports(ref);
}

/// Cancela um serviço aberto ou atribuído. O estado do serviço aparece também
/// nas solicitações do Prestador e nos relatórios.
Future<void> cancelService(WidgetRef ref, {required int serviceId}) async {
  await api('/services/$serviceId/cancel', method: 'POST');
  refreshServicesAndReports(ref);
  ref.invalidate(directRequestsProvider);
  ref.invalidate(directRequestProvider);
}

/// Avalia um serviço realizado. O serviço passa a avaliado e mudam a média, o
/// número e as avaliações do Prestador.
Future<void> reviewService(
  WidgetRef ref, {
  required int serviceId,
  required ReviewInput body,
}) async {
  await api('/services/$serviceId/review', method: 'POST', body: body.toJson());
  refreshServices(ref);
  ref.invalidate(profileProvider);
  ref.invalidate(reviewsProvider);
  ref.invalidate(searchProvidersProvider);
}
