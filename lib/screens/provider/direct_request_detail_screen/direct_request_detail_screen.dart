import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/direct_requests.dart';
import 'package:localhub/data/proposals.dart';
import 'package:localhub/models/direct_request.dart';
import 'package:localhub/models/proposal.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/proposals/proposal_form.dart';
import 'package:localhub/widgets/ui/confirm_dialog.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

import 'direct_request_header.dart';

/// Detalhe de uma solicitação direta recebida: o serviço e o histórico e,
/// enquanto estiver pendente, a proposta ou a recusa. Depois de respondida,
/// leva à proposta apresentada. Não permite cancelar o serviço.
class DirectRequestDetailScreen extends ConsumerStatefulWidget {
  const DirectRequestDetailScreen({super.key, required this.directRequestId});

  final int directRequestId;

  @override
  ConsumerState<DirectRequestDetailScreen> createState() =>
      _DirectRequestDetailScreenState();
}

class _DirectRequestDetailScreenState
    extends ConsumerState<DirectRequestDetailScreen> {
  bool _submitting = false;

  Future<void> _refresh() =>
      ref.refresh(directRequestProvider(widget.directRequestId).future);

  // Chamado pelo formulário: os erros voltam a ser lançados para ele pôr os
  // erros do backend junto aos campos
  Future<void> _handleProposalSubmit(int serviceId, ProposalInput body) async {
    setState(() => _submitting = true);
    try {
      await submitProposal(ref, serviceId: serviceId, body: body);
      await _refresh();
      if (mounted) {
        showMessage('Proposta enviada.');
      }
    } catch (e) {
      if (mounted) {
        await handleActionError(e, onConflict: _refresh);
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _handleDeclinePressed(String serviceTitle) async {
    // A recusa não pode ser anulada: só avança depois de confirmada
    final confirmed = await confirmAction(
      context,
      title: 'Recusar solicitação?',
      subject: serviceTitle,
      message:
          'A solicitação passa a recusada e deixa de poder apresentar '
          'proposta. Esta ação não pode ser anulada.',
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await declineDirectRequest(ref, directRequestId: widget.directRequestId);
      await _refresh();
      if (mounted) {
        showMessage('Solicitação recusada.');
      }
    } catch (e) {
      if (mounted) {
        await handleActionError(e, onConflict: _refresh);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(directRequestProvider(widget.directRequestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da solicitação')),
      body: request.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        // Uma solicitação que não existe ou que não é deste Prestador não volta
        // com «Tentar outra vez»
        error: (e, _) => e is ApiError && e.status == 404
            ? const _RequestNotFound()
            : ErrorStateView(
                error: e,
                onRetry: () => ref.invalidate(
                  directRequestProvider(widget.directRequestId),
                ),
              ),
        data: (data) {
          // A solicitação pode estar pendente com o serviço já atribuído a outro
          // Prestador ou cancelado. Aí o backend recusaria a proposta, por isso
          // só se mostra o formulário com o serviço aberto
          final canRespond =
              data.status == DirectRequestStatus.pending &&
              data.service.status == ServiceStatus.open;
          final busy = request.isLoading || _submitting;
          final proposalId = data.proposalId;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                DirectRequestHeader(data: data),
                const SizedBox(height: AppSpacing.md),
                if (canRespond)
                  ProposalForm(
                    enabled: !busy,
                    onSubmit: (body) =>
                        _handleProposalSubmit(data.service.serviceId, body),
                    onDecline: () => _handleDeclinePressed(data.service.title),
                  )
                else if (proposalId != null)
                  OutlinedButton(
                    onPressed: () => context.push(
                      '/prestador/solicitacoes/${widget.directRequestId}'
                      '/proposta/$proposalId',
                    ),
                    child: const Text('Ver proposta'),
                  )
                else if (data.status == DirectRequestStatus.declined &&
                    data.responseDate != null)
                  _Notice(
                    'Recusou esta solicitação a '
                    '${formatDate(data.responseDate!)}.',
                  )
                else if (data.status == DirectRequestStatus.voided)
                  const _Notice('Esta solicitação ficou sem efeito.'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _RequestNotFound extends StatelessWidget {
  const _RequestNotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Solicitação não encontrada',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'A solicitação que procura não existe.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.go('/prestador/solicitacoes'),
              child: const Text('Voltar às solicitações'),
            ),
          ],
        ),
      ),
    );
  }
}
