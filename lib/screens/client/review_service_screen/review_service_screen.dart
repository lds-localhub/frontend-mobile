import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/data/services.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

import 'review_form.dart';

/// Avaliação de um serviço realizado, aberta a partir do detalhe; no fim, volta
/// ao detalhe, que deixa de mostrar «Avaliar serviço».
class ReviewServiceScreen extends ConsumerWidget {
  const ReviewServiceScreen({super.key, required this.serviceId});

  final int serviceId;

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    ReviewInput body,
  ) async {
    try {
      await reviewService(ref, serviceId: serviceId, body: body);
      if (context.mounted) {
        showMessage('Avaliação registada.');
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        // Estado diferente no servidor (ex.: o serviço já foi avaliado): volta
        // ao detalhe atualizado
        await handleActionError(
          e,
          onConflict: () async {
            refreshServices(ref);
            if (context.mounted) {
              context.pop();
            }
          },
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // O detalhe já foi lido no ecrã de onde se veio
    final service = ref.watch(serviceProvider(serviceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar serviço')),
      body: service.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(
          error: e,
          onRetry: () => ref.invalidate(serviceProvider(serviceId)),
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ReviewForm(
                  providerName: data.acceptedProviderName ?? 'o Prestador',
                  onSubmit: (body) => _handleSubmit(context, ref, body),
                  onCancel: () => context.pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
