import 'category.dart';
import 'service.dart';
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

/// Parâmetros da lista das solicitações diretas do Prestador; sem
/// [status], todas.
typedef DirectRequestsParams = ({DirectRequestStatus? status, int page});

/// Resumo do serviço de uma solicitação na lista.
class DirectRequestServiceRef {
  const DirectRequestServiceRef({
    required this.serviceId,
    required this.title,
    required this.serviceCategory,
    required this.requestedStartDate,
    required this.requestedEndDate,
    required this.clientName,
  });

  factory DirectRequestServiceRef.fromJson(Map<String, dynamic> json) =>
      DirectRequestServiceRef(
        serviceId: json['serviceId'] as int,
        title: json['title'] as String,
        serviceCategory: CategoryRef.fromJson(
          json['serviceCategory'] as Map<String, dynamic>,
        ),
        requestedStartDate: json['requestedStartDate'] as String,
        requestedEndDate: json['requestedEndDate'] as String?,
        clientName: json['clientName'] as String,
      );

  final int serviceId;
  final String title;
  final CategoryRef serviceCategory;
  final String requestedStartDate;
  final String? requestedEndDate;
  final String clientName;
}

/// Solicitação direta na lista do Prestador.
class DirectRequestItem {
  const DirectRequestItem({
    required this.directRequestId,
    required this.status,
    required this.proposalId,
    required this.service,
  });

  factory DirectRequestItem.fromJson(Map<String, dynamic> json) =>
      DirectRequestItem(
        directRequestId: json['directRequestId'] as int,
        status: DirectRequestStatus.fromJson(json['status'] as String),
        proposalId: json['proposalId'] as int?,
        service: DirectRequestServiceRef.fromJson(
          json['service'] as Map<String, dynamic>,
        ),
      );

  final int directRequestId;
  final DirectRequestStatus status;
  final int? proposalId;
  final DirectRequestServiceRef service;
}

/// Serviço de uma solicitação, no detalhe do Prestador, sem os
/// contactos do Cliente.
class DirectRequestServiceDetail {
  const DirectRequestServiceDetail({
    required this.serviceId,
    required this.title,
    required this.serviceCategory,
    required this.description,
    required this.location,
    required this.distanceKm,
    required this.requestedStartDate,
    required this.requestedEndDate,
    required this.status,
    required this.creationDate,
    required this.clientName,
    required this.history,
  });

  factory DirectRequestServiceDetail.fromJson(Map<String, dynamic> json) =>
      DirectRequestServiceDetail(
        serviceId: json['serviceId'] as int,
        title: json['title'] as String,
        serviceCategory: CategoryRef.fromJson(
          json['serviceCategory'] as Map<String, dynamic>,
        ),
        description: json['description'] as String,
        location: json['location'] as String,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        requestedStartDate: json['requestedStartDate'] as String,
        requestedEndDate: json['requestedEndDate'] as String?,
        status: ServiceStatus.fromJson(json['status'] as String),
        creationDate: json['creationDate'] as String,
        clientName: json['clientName'] as String,
        history: [
          for (final item in json['history'] as List)
            ServiceStatusChangeSummary.fromJson(item as Map<String, dynamic>),
        ],
      );

  final int serviceId;
  final String title;
  final CategoryRef serviceCategory;
  final String description;
  final String location;

  /// Distância à localização do perfil do Prestador.
  final double? distanceKm;
  final String requestedStartDate;
  final String? requestedEndDate;
  final ServiceStatus status;
  final String creationDate;
  final String clientName;
  final List<ServiceStatusChangeSummary> history;
}

/// Detalhe de uma solicitação direta do Prestador.
class DirectRequestDetail {
  const DirectRequestDetail({
    required this.directRequestId,
    required this.status,
    required this.creationDate,
    required this.responseDate,
    required this.service,
    required this.proposalId,
  });

  factory DirectRequestDetail.fromJson(Map<String, dynamic> json) =>
      DirectRequestDetail(
        directRequestId: json['directRequestId'] as int,
        status: DirectRequestStatus.fromJson(json['status'] as String),
        creationDate: json['creationDate'] as String,
        responseDate: json['responseDate'] as String?,
        service: DirectRequestServiceDetail.fromJson(
          json['service'] as Map<String, dynamic>,
        ),
        proposalId: json['proposalId'] as int?,
      );

  final int directRequestId;
  final DirectRequestStatus status;

  /// Data em que o Prestador recebeu a solicitação.
  final String creationDate;

  /// Data da proposta ou da recusa; `null` enquanto estiver pendente.
  final String? responseDate;
  final DirectRequestServiceDetail service;

  /// Proposta que o Prestador apresentou nesta solicitação, se houver.
  final int? proposalId;
}
