import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// O Page do Navigator tem o mesmo nome que a lista paginada da API
import 'package:material_ui/material_ui.dart' hide Page;

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/profiles.dart';
import 'package:localhub/models/page.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/profiles/review_tile.dart';
import 'package:localhub/widgets/ui/empty_state_view.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/loading_view.dart';

/// Perfil profissional de um Prestador: cabeçalho, apresentação, contactos,
/// experiência, área de atuação e as 3 avaliações mais recentes.
///
/// Com [isOwn] (o próprio Prestador) tem «Editar perfil»; visto pelo Cliente,
/// mostra a [distanceKm] da pesquisa e, com [showDirectRequest], «Fazer
/// solicitação direta» na categoria [serviceCategoryId].
class ProviderProfileView extends ConsumerWidget {
  const ProviderProfileView({
    super.key,
    required this.professionalProfileId,
    required this.isOwn,
    this.distanceKm,
    this.serviceCategoryId,
    this.showDirectRequest = false,
  });

  final int professionalProfileId;
  final bool isOwn;
  final double? distanceKm;
  final int? serviceCategoryId;
  final bool showDirectRequest;

  ReviewsParams get _reviewsParams =>
      (professionalProfileId: professionalProfileId, page: 1, pageSize: 3);

  Future<void> _refresh(WidgetRef ref) => Future.wait([
    ref.refresh(profileProvider(professionalProfileId).future),
    ref.refresh(reviewsProvider(_reviewsParams).future),
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(professionalProfileId));

    return profile.when(
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (e, _) => ErrorStateView(
        error: e,
        onRetry: () => ref.invalidate(profileProvider(professionalProfileId)),
      ),
      data: (data) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _Header(profile: data, isOwn: isOwn),
            const SizedBox(height: AppSpacing.md),
            _TextCard(title: 'Apresentação', text: data.introduction),
            const SizedBox(height: AppSpacing.md),
            _TextCard(title: 'Contactos', text: data.contactDetails),
            const SizedBox(height: AppSpacing.md),
            _TextCard(title: 'Experiência', text: data.experience),
            const SizedBox(height: AppSpacing.md),
            _ServiceAreaCard(
              profile: data,
              title: isOwn
                  ? 'Área de atuação'
                  : 'Localização e raio de atuação',
              distanceKm: isOwn ? null : distanceKm,
            ),
            const SizedBox(height: AppSpacing.md),
            _ReviewsCard(
              reviews: ref.watch(reviewsProvider(_reviewsParams)),
              onRetry: () => ref.invalidate(reviewsProvider(_reviewsParams)),
            ),
            if (showDirectRequest && !isOwn) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go(
                  '/cliente/criar?${toQueryString({'professionalProfileId': professionalProfileId, 'serviceCategoryId': serviceCategoryId})}',
                  // Cada pedido recomeça o formulário, mesmo com o endereço
                  // igual ao da última vez (ex.: depois de criar um serviço)
                  extra: Object(),
                ),
                child: const Text('Fazer solicitação direta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.isOwn});

  final Profile profile;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final averageRating = profile.averageRating;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            InitialsAvatar(name: profile.name, radius: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final category in profile.serviceCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      category.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (averageRating == null)
              Text('Sem avaliações', style: theme.textTheme.bodyMedium)
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 20, color: colors.tertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: formatAverageRating(averageRating),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text:
                              ' (${profile.reviewCount} '
                              '${profile.reviewCount == 1 ? 'avaliação' : 'avaliações'})',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (isOwn) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.push('/prestador/conta/perfil/editar'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(text, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ServiceAreaCard extends StatelessWidget {
  const _ServiceAreaCard({
    required this.profile,
    required this.title,
    required this.distanceKm,
  });

  final Profile profile;
  final String title;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final distance = distanceKm;
    final radius = 'Raio de atuação: ${profile.serviceRadiusKm} km';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _ServiceAreaIllustration(radiusKm: profile.serviceRadiusKm),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    profile.address,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              distance == null
                  ? radius
                  : '$radius · Distância: ${formatDistance(distance)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ilustração da área de atuação: a morada ao centro e o raio à volta, sobre
/// uma grelha que lembra um mapa (não é um mapa real).
class _ServiceAreaIllustration extends StatelessWidget {
  const _ServiceAreaIllustration({required this.radiusKm});

  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: SizedBox(
          height: 150,
          child: CustomPaint(
            painter: _ServiceAreaPainter(
              background: colors.secondaryContainer,
              grid: colors.outlineVariant,
              area: colors.primaryContainer,
              border: colors.primary,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, color: colors.primary),
                  Text(
                    '$radiusKm km',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceAreaPainter extends CustomPainter {
  const _ServiceAreaPainter({
    required this.background,
    required this.grid,
    required this.area,
    required this.border,
  });

  final Color background;
  final Color grid;
  final Color area;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = size.center(Offset.zero);
    final radius = size.height * 0.42;
    canvas.drawCircle(center, radius, Paint()..color = area);

    final borderPaint = Paint()
      ..color = border
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashes = 36;
    const sweep = 2 * pi / dashes;
    final rect = Rect.fromCircle(center: center, radius: radius);
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.6, false, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_ServiceAreaPainter oldDelegate) =>
      background != oldDelegate.background ||
      grid != oldDelegate.grid ||
      area != oldDelegate.area ||
      border != oldDelegate.border;
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.reviews, required this.onRetry});

  final AsyncValue<Page<Review>> reviews;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Avaliações', style: theme.textTheme.titleMedium),
            reviews.when(
              skipLoadingOnReload: true,
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorStateView(error: e, onRetry: onRetry),
              data: (page) => page.items.isEmpty
                  ? const EmptyStateView(message: 'Ainda não tem avaliações.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final review in page.items) ...[
                          const Divider(height: AppSpacing.lg),
                          ReviewTile(review: review),
                        ],
                        const Divider(height: AppSpacing.md),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Ver todas as avaliações (${page.total})',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          // A lista completa fica por baixo do perfil aberto, no mesmo separador
                          onTap: () => context.push(
                            '${GoRouterState.of(context).uri.path}/avaliacoes',
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
