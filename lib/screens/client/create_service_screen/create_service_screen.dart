import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/data/profiles.dart';
import 'package:localhub/data/services.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/initials_avatar.dart';
import 'package:localhub/widgets/ui/loading_view.dart';
import 'package:localhub/widgets/ui/messages.dart';

import 'provider_selection_tab.dart';
import 'service_details_tab.dart';

/// Prestador selecionado para uma solicitação direta, com as categorias (para
/// limitar a categoria do serviço às que todos têm).
typedef SelectedProvider = ({
  int professionalProfileId,
  String name,
  List<int> serviceCategoryIds,
});

/// Disponibilidade pedida: uma data ou um intervalo de datas.
enum DateMode { single, range }

const _detailFields = {
  'serviceCategoryId',
  'title',
  'description',
  'location',
  'requestedStartDate',
  'requestedEndDate',
};

/// Criação de um serviço nas duas modalidades (M08, M11, com o separador
/// «Prestadores», M17), no separador «Criar».
///
/// Com [providerId] (vindo do perfil de um Prestador), começa em solicitação
/// direta com esse Prestador já selecionado e a categoria [categoryId]. Um ID
/// inválido ([invalidProviderId]) ou de um Prestador que já não existe começa
/// também em solicitação direta, sem ninguém selecionado e com um aviso.
class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({
    super.key,
    this.providerId,
    this.invalidProviderId = false,
    this.categoryId,
  });

  final int? providerId;
  final bool invalidProviderId;
  final int? categoryId;

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  // Cada reposição (depois de criar ou de «Cancelar») recria o formulário
  // vazio, já sem o Prestador vindo do perfil
  int _resets = 0;

  void _handleReset() => setState(() => _resets++);

  @override
  Widget build(BuildContext context) {
    final providerId = widget.providerId;
    final registeredAddress = ref.watch(meProvider).value?.address;
    Widget form(Profile? preselected, {bool providerUnavailable = false}) =>
        _CreateServiceForm(
          key: ValueKey(_resets),
          preselected: preselected,
          providerUnavailable: providerUnavailable,
          initialCategoryId: preselected == null ? null : widget.categoryId,
          registeredAddress: registeredAddress,
          onReset: _handleReset,
        );

    final Widget body;
    if (_resets > 0) {
      body = form(null);
    } else if (providerId == null) {
      body = form(null, providerUnavailable: widget.invalidProviderId);
    } else {
      // O formulário só começa depois de chegar o perfil, para a seleção ter o nome certo
      final profile = ref.watch(profileProvider(providerId));
      body = profile.when(
        // Ao voltar à aplicação o perfil é pedido outra vez: o formulário
        // aberto não pode ser trocado pelo carregamento, nem por um erro
        skipLoadingOnReload: true,
        skipError: true,
        loading: () => const LoadingView(),
        // Um Prestador que já não existe não volta com «Tentar outra vez»: o
        // formulário abre sem ele, com o mesmo aviso de um ID inválido
        error: (e, _) => e is ApiError && e.status == 404
            ? form(null, providerUnavailable: true)
            : ErrorStateView(
                error: e,
                onRetry: () => ref.invalidate(profileProvider(providerId)),
              ),
        data: form,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar serviço'),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}

class _CreateServiceForm extends ConsumerStatefulWidget {
  const _CreateServiceForm({
    super.key,
    required this.preselected,
    required this.providerUnavailable,
    required this.initialCategoryId,
    required this.registeredAddress,
    required this.onReset,
  });

  final Profile? preselected;
  final bool providerUnavailable;
  final int? initialCategoryId;
  final String? registeredAddress;
  final VoidCallback onReset;

  @override
  ConsumerState<_CreateServiceForm> createState() => _CreateServiceFormState();
}

class _CreateServiceFormState extends ConsumerState<_CreateServiceForm> {
  final _detailsFormKey = GlobalKey<FormState>();
  final _providersFormKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  late final TextEditingController _location;
  var _autovalidateMode = AutovalidateMode.disabled;
  // A falta de Prestadores só é assinalada depois de uma tentativa de envio,
  // não logo ao abrir o separador com «Seguinte»
  var _providersAutovalidateMode = AutovalidateMode.disabled;
  late ProposalModel _proposalModel;
  int? _serviceCategoryId;
  var _dateMode = DateMode.single;
  String? _startDate;
  String? _endDate;
  var _providers = <SelectedProvider>[];
  int _tab = 0;
  bool _submitting = false;
  var _serverErrors = <String, String>{};
  String? _generalError;
  String? _positionError;

  @override
  void initState() {
    super.initState();
    _location = TextEditingController(text: widget.registeredAddress ?? '');
    final preselected = widget.preselected;
    _proposalModel = preselected == null && !widget.providerUnavailable
        ? ProposalModel.public
        : ProposalModel.directRequest;
    _serviceCategoryId = widget.initialCategoryId;
    if (preselected != null) {
      _providers = [
        (
          professionalProfileId: preselected.professionalProfileId,
          name: preselected.name,
          serviceCategoryIds: [
            for (final c in preselected.serviceCategories) c.serviceCategoryId,
          ],
        ),
      ];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  bool get _isDirect => _proposalModel == ProposalModel.directRequest;

  // Categorias que todos os Prestadores selecionados têm; sem seleção, todas
  List<int>? get _onlyCategoryIds {
    if (_providers.isEmpty) {
      return null;
    }
    return [
      for (final id in _providers.first.serviceCategoryIds)
        if (_providers.every((p) => p.serviceCategoryIds.contains(id))) id,
    ];
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field) || _generalError != null) {
      setState(() {
        _serverErrors = {..._serverErrors}..remove(field);
        _generalError = null;
      });
    }
  }

  void _handleModelChanged(ProposalModel model) {
    setState(() {
      _proposalModel = model;
      _tab = 0;
      // Aberto a propostas não tem destinatários
      if (model == ProposalModel.public) {
        _providers = [];
      }
    });
  }

  void _handleProvidersChanged(List<SelectedProvider> providers) {
    setState(() => _providers = providers);
    _clearServerError('providers');
  }

  void _handleLocationChanged() {
    if (_positionError != null) {
      setState(() => _positionError = null);
    }
    _clearServerError('location');
  }

  // Os Prestadores procuram-se pela categoria e pelo local: só se passa a
  // esse separador com os detalhes válidos
  void _handleNextPressed() {
    setState(() => _autovalidateMode = AutovalidateMode.always);
    if (_detailsFormKey.currentState!.validate()) {
      setState(() => _tab = 1);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _serverErrors = {};
      _generalError = null;
      _autovalidateMode = AutovalidateMode.always;
      _providersAutovalidateMode = AutovalidateMode.always;
    });
    final detailsValid = _detailsFormKey.currentState!.validate();
    final providersValid = _providersFormKey.currentState?.validate() ?? true;
    if (!detailsValid || !providersValid) {
      setState(() => _tab = detailsValid ? 1 : 0);
      return;
    }

    final body = CreateServiceInput(
      proposalModel: _proposalModel,
      serviceCategoryId: _serviceCategoryId!,
      title: _title.text.trim(),
      description: _description.text.trim(),
      location: _location.text.trim(),
      requestedStartDate: _startDate!,
      requestedEndDate: _dateMode == DateMode.range ? _endDate : null,
      professionalProfileIds: _isDirect
          ? [for (final p in _providers) p.professionalProfileId]
          : null,
    );

    setState(() => _submitting = true);
    try {
      final service = await createService(ref, body: body);
      if (!mounted) {
        return;
      }
      showMessage('Serviço criado.');
      context.go('/cliente/servicos/${service.serviceId}');
      widget.onReset();
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e is ApiError && (e.errors != null || e.status == 400)) {
        final errors = serverFieldErrors(e, {
          'professionalProfileIds': 'providers',
        });
        setState(() {
          _serverErrors = errors;
          _generalError = e.errors == null ? e.detail : null;
          if (errors.keys.any(_detailFields.contains)) {
            _tab = 0;
          } else if (errors.containsKey('providers')) {
            _tab = 1;
          }
        });
      } else {
        await handleActionError(e);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildSubmitButtons() {
    final count = _providers.length;
    final children = <Widget>[
      FormErrorText(_generalError),
      if (!_isDirect)
        FilledButton(
          onPressed: _submitting ? null : _handleSubmit,
          child: const Text('Publicar serviço'),
        )
      else if (_tab == 0)
        FilledButton(
          onPressed: _submitting ? null : _handleNextPressed,
          child: Text('Seguinte: Prestadores ($count) ›'),
        )
      else ...[
        FilledButton(
          onPressed: _submitting ? null : _handleSubmit,
          child: Text('Enviar solicitações ($count)'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _submitting ? null : () => setState(() => _tab = 0),
          child: const Text('Voltar aos detalhes'),
        ),
      ],
      if (_tab == 0) ...[
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _submitting ? null : widget.onReset,
          child: const Text('Cancelar'),
        ),
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preselected = widget.preselected;
    final showPreselected =
        preselected != null &&
        _providers.any(
          (p) => p.professionalProfileId == preselected.professionalProfileId,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Modalidade',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ProposalModel>(
            segments: const [
              ButtonSegment(
                value: ProposalModel.public,
                label: Text('Aberto a propostas'),
              ),
              ButtonSegment(
                value: ProposalModel.directRequest,
                label: Text('Solicitação direta'),
              ),
            ],
            selected: {_proposalModel},
            showSelectedIcon: false,
            onSelectionChanged: _submitting
                ? null
                : (selection) => _handleModelChanged(selection.first),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isDirect
                ? 'Só os Prestadores escolhidos recebem o pedido.'
                : 'Todos os Prestadores compatíveis podem enviar proposta.',
            style: theme.textTheme.bodySmall,
          ),
          if (_isDirect) ...[
            const SizedBox(height: AppSpacing.sm),
            _TabHeader(
              index: _tab,
              labels: ['Detalhes', 'Prestadores (${_providers.length})'],
              onSelected: (index) =>
                  index == 1 ? _handleNextPressed() : setState(() => _tab = 0),
            ),
          ],
          if (showPreselected && _tab == 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _PreselectedBanner(name: preselected.name),
          ],
          if (widget.providerUnavailable &&
              _isDirect &&
              _providers.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'O Prestador indicado não existe ou já não está disponível.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Os dois separadores ficam montados, para o envio validar todos os campos
          Visibility(
            visible: _tab == 0,
            maintainState: true,
            child: Form(
              key: _detailsFormKey,
              autovalidateMode: _autovalidateMode,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: ServiceDetailsTab(
                    title: _title,
                    description: _description,
                    location: _location,
                    serviceCategoryId: _serviceCategoryId,
                    onlyCategoryIds: _onlyCategoryIds,
                    dateMode: _dateMode,
                    startDate: _startDate,
                    endDate: _endDate,
                    serverErrors: _serverErrors,
                    positionError: _positionError,
                    enabled: !_submitting,
                    onCategoryChanged: (id) =>
                        setState(() => _serviceCategoryId = id),
                    onDateModeChanged: (mode) =>
                        setState(() => _dateMode = mode),
                    onStartDateChanged: (day) =>
                        setState(() => _startDate = day),
                    onEndDateChanged: (day) => setState(() => _endDate = day),
                    onFieldChanged: (field) => field == 'location'
                        ? _handleLocationChanged()
                        : _clearServerError(field),
                    onPositionError: (error) =>
                        setState(() => _positionError = error),
                  ),
                ),
              ),
            ),
          ),
          if (_isDirect)
            Visibility(
              visible: _tab == 1,
              maintainState: true,
              child: Form(
                key: _providersFormKey,
                autovalidateMode: _providersAutovalidateMode,
                child: FormField<void>(
                  validator: (_) => _providers.isEmpty
                      ? 'Selecione pelo menos um Prestador.'
                      : null,
                  forceErrorText: _serverErrors['providers'],
                  builder: (field) => ProviderSelectionTab(
                    serviceCategoryId: _serviceCategoryId,
                    location: _location.text,
                    selected: _providers,
                    errorText: field.errorText,
                    active: _tab == 1,
                    enabled: !_submitting,
                    onChanged: (providers) {
                      _handleProvidersChanged(providers);
                      field.didChange(null);
                    },
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          _buildSubmitButtons(),
        ],
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.index,
    required this.labels,
    required this.onSelected,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: InkWell(
              onTap: () => onSelected(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == index
                          ? colors.primary
                          : colors.outlineVariant,
                      width: i == index ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: i == index
                        ? colors.primary
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PreselectedBanner extends StatelessWidget {
  const _PreselectedBanner({required this.name});

  final String name;

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
          InitialsAvatar(name: name, radius: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Pedido iniciado no perfil de '),
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ', que já está selecionada.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
