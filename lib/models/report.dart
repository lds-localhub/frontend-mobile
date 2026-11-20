import 'category.dart';
import 'service.dart';

/// Período dos relatórios (E33, E34): datas `AAAA-MM-DD`, opcionais e
/// inclusivas, aplicadas à data de criação de cada serviço.
typedef ReportParams = ({String? startDate, String? endDate});

/// Número de serviços de uma categoria.
class CategoryCount {
  const CategoryCount({
    required this.serviceCategoryId,
    required this.name,
    required this.count,
  });

  factory CategoryCount.fromJson(Map<String, dynamic> json) => CategoryCount(
    serviceCategoryId: json['serviceCategoryId'] as int,
    name: json['name'] as String,
    count: json['count'] as int,
  );

  final int serviceCategoryId;
  final String name;
  final int count;
}

/// Número de serviços num estado.
class StatusCount {
  const StatusCount({required this.status, required this.count});

  factory StatusCount.fromJson(Map<String, dynamic> json) => StatusCount(
    status: ServiceStatus.fromJson(json['status'] as String),
    count: json['count'] as int,
  );

  final ServiceStatus status;
  final int count;
}

/// Serviço realizado no histórico do relatório do Cliente.
class CompletedServiceRow {
  const CompletedServiceRow({
    required this.serviceId,
    required this.actualCompletionDate,
    required this.serviceCategory,
    required this.providerName,
    required this.amount,
  });

  factory CompletedServiceRow.fromJson(Map<String, dynamic> json) =>
      CompletedServiceRow(
        serviceId: json['serviceId'] as int,
        actualCompletionDate: json['actualCompletionDate'] as String,
        serviceCategory: CategoryRef.fromJson(
          json['serviceCategory'] as Map<String, dynamic>,
        ),
        providerName: json['providerName'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  final int serviceId;
  final String actualCompletionDate;
  final CategoryRef serviceCategory;
  final String providerName;
  final double amount;
}

/// Relatório de atividade do Cliente (E33).
class ClientReport {
  const ClientReport({
    required this.contractedServices,
    required this.byCategory,
    required this.byStatus,
    required this.totalAcceptedAmount,
    required this.completedHistory,
  });

  factory ClientReport.fromJson(Map<String, dynamic> json) => ClientReport(
    contractedServices: json['contractedServices'] as int,
    byCategory: [
      for (final item in json['byCategory'] as List)
        CategoryCount.fromJson(item as Map<String, dynamic>),
    ],
    byStatus: [
      for (final item in json['byStatus'] as List)
        StatusCount.fromJson(item as Map<String, dynamic>),
    ],
    totalAcceptedAmount: (json['totalAcceptedAmount'] as num).toDouble(),
    completedHistory: [
      for (final item in json['completedHistory'] as List)
        CompletedServiceRow.fromJson(item as Map<String, dynamic>),
    ],
  );

  final int contractedServices;
  final List<CategoryCount> byCategory;
  final List<StatusCount> byStatus;
  final double totalAcceptedAmount;
  final List<CompletedServiceRow> completedHistory;
}

/// Propostas do Prestador aceites e recusadas.
class ProposalCounts {
  const ProposalCounts({required this.accepted, required this.declined});

  factory ProposalCounts.fromJson(Map<String, dynamic> json) => ProposalCounts(
    accepted: json['accepted'] as int,
    declined: json['declined'] as int,
  );

  final int accepted;
  final int declined;
}

/// Avaliações recebidas num mês (`AAAA-MM`) e a média, `null` sem avaliações.
class MonthlyRating {
  const MonthlyRating({
    required this.month,
    required this.reviewCount,
    required this.averageRating,
  });

  factory MonthlyRating.fromJson(Map<String, dynamic> json) => MonthlyRating(
    month: json['month'] as String,
    reviewCount: json['reviewCount'] as int,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
  );

  final String month;
  final int reviewCount;
  final double? averageRating;
}

/// Relatório de atividade do Prestador (E34).
class ProviderReport {
  const ProviderReport({
    required this.completedServices,
    required this.byCategory,
    required this.byStatus,
    required this.directRequestsReceived,
    required this.proposals,
    required this.totalAcceptedAmount,
    required this.ratingEvolution,
  });

  factory ProviderReport.fromJson(Map<String, dynamic> json) => ProviderReport(
    completedServices: json['completedServices'] as int,
    byCategory: [
      for (final item in json['byCategory'] as List)
        CategoryCount.fromJson(item as Map<String, dynamic>),
    ],
    byStatus: [
      for (final item in json['byStatus'] as List)
        StatusCount.fromJson(item as Map<String, dynamic>),
    ],
    directRequestsReceived: json['directRequestsReceived'] as int,
    proposals: ProposalCounts.fromJson(
      json['proposals'] as Map<String, dynamic>,
    ),
    totalAcceptedAmount: (json['totalAcceptedAmount'] as num).toDouble(),
    ratingEvolution: [
      for (final item in json['ratingEvolution'] as List)
        MonthlyRating.fromJson(item as Map<String, dynamic>),
    ],
  );

  final int completedServices;
  final List<CategoryCount> byCategory;
  final List<StatusCount> byStatus;
  final int directRequestsReceived;
  final ProposalCounts proposals;
  final double totalAcceptedAmount;
  final List<MonthlyRating> ratingEvolution;
}
