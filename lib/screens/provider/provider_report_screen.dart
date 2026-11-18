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

/// Relatório de atividade do Prestador por período (M25).
class ProviderReportScreen extends ConsumerStatefulWidget {
  const ProviderReportScreen({super.key});

  @override
  ConsumerState<ProviderReportScreen> createState() =>
      _ProviderReportScreenState();
}

class _ProviderReportScreenState extends ConsumerState<ProviderReportScreen> {
  ReportParams _period = (startDate: null, endDate: null);

  Future<void> _refresh() =>
      ref.refresh(providerReportProvider(_period).future);

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(providerReportProvider(_period));

    return Scaffold(
      appBar: AppBar(title: const Text('Relatório do Prestador')),
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
                onRetry: () => ref.invalidate(providerReportProvider(_period)),
              ),
              data: (data) => _ProviderReportBody(report: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderReportBody extends StatelessWidget {
  const _ProviderReportBody({required this.report});

  final ProviderReport report;

  @override
  Widget build(BuildContext context) {
    // A evolução da classificação segue a data das avaliações e não a dos
    // serviços: pode ter meses mesmo quando o período não tem atividade
    final hasActivity =
        report.completedServices > 0 ||
        report.directRequestsReceived > 0 ||
        report.proposals.accepted > 0 ||
        report.proposals.declined > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasActivity)
          const EmptyStateView(message: 'Sem atividade no período escolhido.')
        else ...[
          _StatRow(
            first: StatCard(
              value: '${report.completedServices}',
              label: 'Serviços realizados',
            ),
            second: StatCard(
              value: '${report.directRequestsReceived}',
              label: 'Solicitações diretas',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatRow(
            first: StatCard(
              value: '${report.proposals.accepted}',
              label: 'Propostas aceites',
            ),
            second: StatCard(
              value: '${report.proposals.declined}',
              label: 'Propostas recusadas',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatCard(
            value: formatCurrency(report.totalAcceptedAmount),
            label: 'Valor das propostas aceites',
            highlighted: true,
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
        ],
        if (report.ratingEvolution.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _RatingEvolution(months: report.ratingEvolution),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: second),
        ],
      ),
    );
  }
}

class _RatingEvolution extends StatelessWidget {
  const _RatingEvolution({required this.months});

  final List<MonthlyRating> months;

  String _reviewCount(int count) => switch (count) {
    0 => 'sem avaliações',
    1 => '1 avaliação',
    _ => '$count avaliações',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strong = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return ReportCard(
      title: 'Evolução da classificação média',
      child: Column(
        children: [
          for (final month in months)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatMonth(month.month), style: strong),
                        Text(
                          _reviewCount(month.reviewCount),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    month.averageRating == null
                        ? '—'
                        : month.averageRating!
                              .toStringAsFixed(1)
                              .replaceAll('.', ','),
                    style: strong,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
