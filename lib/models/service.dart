import 'category.dart';
import 'direct_request.dart';
import 'profile.dart';
import 'proposal.dart';
import 'tone.dart';
import 'user.dart';

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

/// Modalidade de um serviço: com solicitações diretas ou aberto a propostas.
enum ProposalModel {
  public('PUBLIC', 'Aberto a propostas'),
  directRequest('DIRECT_REQUEST', 'Solicitações diretas');

  const ProposalModel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static ProposalModel fromJson(String value) =>
      values.firstWhere((m) => m.apiValue == value);
}

/// Alteração de estado de um serviço, só com o papel de quem a fez.
class ServiceStatusChangeSummary {
  const ServiceStatusChangeSummary({
    required this.previousStatus,
    required this.newStatus,
    required this.changedAt,
    required this.changedByRole,
  });

  factory ServiceStatusChangeSummary.fromJson(Map<String, dynamic> json) =>
      ServiceStatusChangeSummary(
        previousStatus: ServiceStatus.fromJson(
          json['previousStatus'] as String,
        ),
        newStatus: ServiceStatus.fromJson(json['newStatus'] as String),
        changedAt: json['changedAt'] as String,
        changedByRole: Role.fromJson(json['changedByRole'] as String),
      );

  final ServiceStatus previousStatus;
  final ServiceStatus newStatus;
  final String changedAt;
  final Role changedByRole;
}

/// Alteração de estado de um serviço do Cliente, com quem a fez.
class ServiceStatusChange extends ServiceStatusChangeSummary {
  const ServiceStatusChange({
    required super.previousStatus,
    required super.newStatus,
    required super.changedAt,
    required super.changedByRole,
    required this.changedByUserId,
    required this.changedByName,
  });

  factory ServiceStatusChange.fromJson(Map<String, dynamic> json) =>
      ServiceStatusChange(
        previousStatus: ServiceStatus.fromJson(
          json['previousStatus'] as String,
        ),
        newStatus: ServiceStatus.fromJson(json['newStatus'] as String),
        changedAt: json['changedAt'] as String,
        changedByRole: Role.fromJson(json['changedByRole'] as String),
        changedByUserId: json['changedByUserId'] as int,
        changedByName: json['changedByName'] as String,
      );

  final int changedByUserId;
  final String changedByName;
}

/// Dados comuns de uma proposta: valor, condições, estado e datas.
class ProposalSummary {
  const ProposalSummary({
    required this.proposalId,
    required this.amount,
    required this.conditions,
    required this.obs,
    required this.status,
    required this.creationDate,
    required this.decisionDate,
  });

  factory ProposalSummary.fromJson(Map<String, dynamic> json) =>
      ProposalSummary(
        proposalId: json['proposalId'] as int,
        amount: (json['amount'] as num).toDouble(),
        conditions: json['conditions'] as String,
        obs: json['obs'] as String?,
        status: ProposalStatus.fromJson(json['status'] as String),
        creationDate: json['creationDate'] as String,
        decisionDate: json['decisionDate'] as String?,
      );

  final int proposalId;
  final double amount;
  final String conditions;
  final String? obs;
  final ProposalStatus status;
  final String creationDate;
  final String? decisionDate;
}

/// Proposta recebida num serviço aberto a propostas, com o Prestador.
class ServiceProposal extends ProposalSummary {
  const ServiceProposal({
    required super.proposalId,
    required super.amount,
    required super.conditions,
    required super.obs,
    required super.status,
    required super.creationDate,
    required super.decisionDate,
    required this.professionalProfile,
  });

  factory ServiceProposal.fromJson(Map<String, dynamic> json) {
    final summary = ProposalSummary.fromJson(json);
    return ServiceProposal(
      proposalId: summary.proposalId,
      amount: summary.amount,
      conditions: summary.conditions,
      obs: summary.obs,
      status: summary.status,
      creationDate: summary.creationDate,
      decisionDate: summary.decisionDate,
      professionalProfile: ProviderRef.fromJson(
        json['professionalProfile'] as Map<String, dynamic>,
      ),
    );
  }

  final ProviderRef professionalProfile;
}

/// Solicitação direta de um serviço, com o Prestador e a proposta associada.
class ServiceDirectRequest {
  const ServiceDirectRequest({
    required this.directRequestId,
    required this.status,
    required this.creationDate,
    required this.responseDate,
    required this.professionalProfile,
    required this.proposal,
  });

  factory ServiceDirectRequest.fromJson(Map<String, dynamic> json) =>
      ServiceDirectRequest(
        directRequestId: json['directRequestId'] as int,
        status: DirectRequestStatus.fromJson(json['status'] as String),
        creationDate: json['creationDate'] as String,
        responseDate: json['responseDate'] as String?,
        professionalProfile: ProviderRef.fromJson(
          json['professionalProfile'] as Map<String, dynamic>,
        ),
        proposal: json['proposal'] == null
            ? null
            : ProposalSummary.fromJson(
                json['proposal'] as Map<String, dynamic>,
              ),
      );

  final int directRequestId;
  final DirectRequestStatus status;
  final String creationDate;
  final String? responseDate;
  final ProviderRef professionalProfile;
  final ProposalSummary? proposal;
}

/// Detalhe de um serviço do Cliente, que é também a resposta da criação.
class ServiceDetail {
  const ServiceDetail({
    required this.serviceId,
    required this.title,
    required this.proposalModel,
    required this.serviceCategory,
    required this.description,
    required this.location,
    required this.requestedStartDate,
    required this.requestedEndDate,
    required this.status,
    required this.creationDate,
    required this.actualCompletionDate,
    required this.clientName,
    required this.reviewed,
    required this.history,
    required this.directRequests,
    required this.proposals,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) => ServiceDetail(
    serviceId: json['serviceId'] as int,
    title: json['title'] as String,
    proposalModel: ProposalModel.fromJson(json['proposalModel'] as String),
    serviceCategory: CategoryRef.fromJson(
      json['serviceCategory'] as Map<String, dynamic>,
    ),
    description: json['description'] as String,
    location: json['location'] as String,
    requestedStartDate: json['requestedStartDate'] as String,
    requestedEndDate: json['requestedEndDate'] as String?,
    status: ServiceStatus.fromJson(json['status'] as String),
    creationDate: json['creationDate'] as String,
    actualCompletionDate: json['actualCompletionDate'] as String?,
    clientName: json['clientName'] as String,
    reviewed: json['reviewed'] as bool,
    history: [
      for (final change in json['history'] as List)
        ServiceStatusChange.fromJson(change as Map<String, dynamic>),
    ],
    directRequests: [
      for (final request in json['directRequests'] as List)
        ServiceDirectRequest.fromJson(request as Map<String, dynamic>),
    ],
    proposals: [
      for (final proposal in json['proposals'] as List)
        ServiceProposal.fromJson(proposal as Map<String, dynamic>),
    ],
  );

  final int serviceId;
  final String title;
  final ProposalModel proposalModel;
  final CategoryRef serviceCategory;
  final String description;
  final String location;
  final String requestedStartDate;
  final String? requestedEndDate;
  final ServiceStatus status;
  final String creationDate;
  final String? actualCompletionDate;
  final String clientName;
  final bool reviewed;
  final List<ServiceStatusChange> history;
  final List<ServiceDirectRequest> directRequests;
  final List<ServiceProposal> proposals;

  /// Prestador da proposta aceite, numa ou noutra modalidade, se houver.
  String? get acceptedProviderName {
    for (final request in directRequests) {
      if (request.proposal?.status == ProposalStatus.accepted) {
        return request.professionalProfile.name;
      }
    }
    for (final proposal in proposals) {
      if (proposal.status == ProposalStatus.accepted) {
        return proposal.professionalProfile.name;
      }
    }
    return null;
  }
}

/// Parâmetros da lista dos serviços do Cliente; sem [status], todos.
typedef ServicesParams = ({ServiceStatus? status, int page});

/// Prestador com a proposta aceite num serviço.
class AssignedProviderRef {
  const AssignedProviderRef({
    required this.professionalProfileId,
    required this.name,
  });

  factory AssignedProviderRef.fromJson(Map<String, dynamic> json) =>
      AssignedProviderRef(
        professionalProfileId: json['professionalProfileId'] as int,
        name: json['name'] as String,
      );

  final int professionalProfileId;
  final String name;
}

/// Serviço na lista do Cliente, igual nas duas modalidades.
class ServiceItem {
  const ServiceItem({
    required this.serviceId,
    required this.title,
    required this.proposalModel,
    required this.serviceCategory,
    required this.status,
    required this.creationDate,
    required this.directRequestsCount,
    required this.proposalsCount,
    required this.pendingProposalsCount,
    required this.assignedProvider,
    required this.reviewed,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
    serviceId: json['serviceId'] as int,
    title: json['title'] as String,
    proposalModel: ProposalModel.fromJson(json['proposalModel'] as String),
    serviceCategory: CategoryRef.fromJson(
      json['serviceCategory'] as Map<String, dynamic>,
    ),
    status: ServiceStatus.fromJson(json['status'] as String),
    creationDate: json['creationDate'] as String,
    directRequestsCount: json['directRequestsCount'] as int,
    proposalsCount: json['proposalsCount'] as int,
    pendingProposalsCount: json['pendingProposalsCount'] as int,
    assignedProvider: switch (json['assignedProvider']) {
      final Map<String, dynamic> provider => AssignedProviderRef.fromJson(
        provider,
      ),
      _ => null,
    },
    reviewed: json['reviewed'] as bool,
  );

  final int serviceId;
  final String title;
  final ProposalModel proposalModel;
  final CategoryRef serviceCategory;
  final ServiceStatus status;
  final String creationDate;

  /// Solicitações diretas em qualquer estado; 0 num serviço aberto a
  /// propostas.
  final int directRequestsCount;

  /// Propostas recebidas em qualquer estado.
  final int proposalsCount;
  final int pendingProposalsCount;
  final AssignedProviderRef? assignedProvider;
  final bool reviewed;
}

/// Corpo da avaliação de um serviço realizado; sem comentário, não é enviado.
class ReviewInput {
  const ReviewInput({required this.rating, this.comment});

  final int rating;
  final String? comment;

  Map<String, Object?> toJson() => {
    'rating': rating,
    if (comment != null) 'comment': comment,
  };
}

/// Corpo da criação de um serviço.
class CreateServiceInput {
  const CreateServiceInput({
    required this.proposalModel,
    required this.serviceCategoryId,
    required this.title,
    required this.description,
    required this.location,
    required this.requestedStartDate,
    this.requestedEndDate,
    this.professionalProfileIds,
  });

  final ProposalModel proposalModel;
  final int serviceCategoryId;
  final String title;
  final String description;
  final String location;
  final String requestedStartDate;

  /// `null` para uma data única.
  final String? requestedEndDate;

  /// Só nas solicitações diretas; aberto a propostas, `null`.
  final List<int>? professionalProfileIds;

  Map<String, Object?> toJson() => {
    'proposalModel': proposalModel.apiValue,
    'serviceCategoryId': serviceCategoryId,
    'title': title,
    'description': description,
    'location': location,
    'requestedStartDate': requestedStartDate,
    'requestedEndDate': requestedEndDate,
    'professionalProfileIds': professionalProfileIds,
  };
}
