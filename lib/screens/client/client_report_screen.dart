import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/reports.dart';
import 'package:localhub/models/report.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/reports/report_card.dart';
import 'package:localhub/widgets/reports/report_period_filter.dart';
import 'package:localhub/widgets/ui/bar_list.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/stat_card.dart';

/// Relatório de atividade do Cliente por período (M14).
class ClientReportScreen extends ConsumerStatefulWidget {
  const ClientReportScreen({super.key});

  @override
  ConsumerState<ClientReportScreen> createState() => _ClientReportScreenState();
}

class _ClientReportScreenState extends ConsumerState<ClientReportScreen> {
  ReportParams _period = (startDate: null, endDate: null);

  Future<void> _refresh() => ref.refresh(clientReportProvider(_period).future);

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(clientReportProvider(_period));

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório do Cliente')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Relatório de atividade',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ReportPeriodFilter(
                  value: _period,
                  onApply: (period) => setState(() => _period = period),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            report.when(
              skipLoadingOnReload: true,
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: LoadingView(),
              ),
              error: (e, _) => ErrorStateView(
                error: e,
                onRetry: () => ref.invalidate(clientReportProvider(_period)),
              ),
              data: (data) => _ClientReportBody(report: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientReportBody extends StatelessWidget {
  const _ClientReportBody({required this.report});

  final ClientReport report;

  @override
  Widget build(BuildContext context) {
    // Um serviço só entra nos indicadores depois de contratado: sem contratados, não há atividade
    if (report.contractedServices == 0) {
      return const EmptyStateView(
        message: 'Sem atividade no período escolhido.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${report.contractedServices}',
                label: 'Serviços contratados',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatCard(
                value: formatCurrency(report.totalAcceptedAmount),
                label: 'Propostas aceites',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ReportCard(
          title: 'Por categoria',
          child: BarList(
            items: [
              for (final c in report.byCategory)
                (label: c.name, value: c.count, tone: null),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ReportCard(
          title: 'Por estado',
          child: BarList(
            items: [
              for (final s in report.byStatus)
                (label: s.status.label, value: s.count, tone: s.status.tone),
            ],
          ),
        ),
        if (report.completedHistory.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ReportCard(
            title: 'Serviços realizados',
            child: Column(
              children: [
                for (final row in report.completedHistory)
                  _CompletedServiceTile(row: row),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CompletedServiceTile extends StatelessWidget {
  const _CompletedServiceTile({required this.row});

  final CompletedServiceRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.providerName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${formatDate(row.actualCompletionDate)} · '
                  '${row.serviceCategory.name}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(row.amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
