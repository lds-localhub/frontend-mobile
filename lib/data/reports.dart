import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/report.dart';

import 'app_lifecycle.dart';

String _periodQuery(ReportParams period) {
  final query = toQueryString({
    'startDate': period.startDate,
    'endDate': period.endDate,
  });
  return query.isEmpty ? '' : '?$query';
}

/// Relatório de atividade do Cliente autenticado no período (E33).
final clientReportProvider = FutureProvider.autoDispose
    .family<ClientReport, ReportParams>((ref, period) async {
      ref.watch(appResumedProvider);
      final json = await api('/reports/client${_periodQuery(period)}');
      return ClientReport.fromJson(json! as Map<String, dynamic>);
    });

/// Relatório de atividade do Prestador autenticado no período (E34).
final providerReportProvider = FutureProvider.autoDispose
    .family<ProviderReport, ReportParams>((ref, period) async {
      ref.watch(appResumedProvider);
      final json = await api('/reports/provider${_periodQuery(period)}');
      return ProviderReport.fromJson(json! as Map<String, dynamic>);
    });
