import 'package:flutter/foundation.dart' show AsyncValueSetter;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/categories.dart';
import 'package:localhub/models/category.dart';
import 'package:localhub/models/profile.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/location/current_position_button.dart';
import 'package:localhub/widgets/profiles/category_selector.dart';
import 'package:localhub/widgets/ui/error_state_view.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Formulário do perfil profissional, comum à criação (sem [initialValues]) e
/// à edição: apresentação, contactos, experiência, categorias ativas, morada
/// e raio de atuação.
///
/// O ecrã faz o pedido em [onSubmit] e trata os erros que não são do
/// formulário; os erros com `errors` têm de voltar a ser lançados, para o
/// formulário os pôr junto aos campos.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialValues,
    this.onCancel,
  });

  final Profile? initialValues;
  final String submitLabel;
  final AsyncValueSetter<ProfileInput> onSubmit;
  final VoidCallback? onCancel;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _introduction;
  late final TextEditingController _contactDetails;
  late final TextEditingController _experience;
  late final TextEditingController _address;
  late final TextEditingController _serviceRadiusKm;
  late List<int> _categoryIds;
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  String? _generalError;
  String? _positionError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialValues;
    _introduction = TextEditingController(text: profile?.introduction);
    _contactDetails = TextEditingController(text: profile?.contactDetails);
    _experience = TextEditingController(text: profile?.experience);
    _address = TextEditingController(text: profile?.address);
    _serviceRadiusKm = TextEditingController(
      text: profile?.serviceRadiusKm.toString(),
    );
    _categoryIds = [
      for (final category
          in profile?.serviceCategories ?? const <CategoryRef>[])
        category.serviceCategoryId,
    ];
  }

  @override
  void dispose() {
    _introduction.dispose();
    _contactDetails.dispose();
    _experience.dispose();
    _address.dispose();
    _serviceRadiusKm.dispose();
    super.dispose();
  }

  // Só as categorias ativas: uma categoria do perfil desativada entretanto já não
  // serve para pesquisas nem para novos serviços, por isso não aparece e sai do
  // perfil ao guardar
  List<int> _activeSelection(List<Category> active) => [
    for (final category in active)
      if (_categoryIds.contains(category.serviceCategoryId))
        category.serviceCategoryId,
  ];

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

  void _handleAddressChanged() {
    _clearServerError('address');
    if (_positionError != null) {
      setState(() => _positionError = null);
    }
  }

  // Usar a posição substitui a morada escrita: o erro do backend sobre ela deixa de valer
  void _handlePositionError(String? error) => setState(() {
    _positionError = error;
    _serverErrors = {..._serverErrors}..remove('address');
  });

  void _handleCategoriesChanged(List<int> categoryIds) {
    setState(() => _categoryIds = categoryIds);
    _clearServerError('serviceCategoryIds');
  }

  Future<void> _handleSubmit(List<Category> categories) async {
    setState(() {
      _serverErrors = {};
      _generalError = null;
      _autovalidateMode = AutovalidateMode.always;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final body = ProfileInput(
      introduction: _introduction.text.trim(),
      contactDetails: _contactDetails.text.trim(),
      experience: _experience.text.trim(),
      serviceCategoryIds: _activeSelection(categories),
      address: _address.text.trim(),
      serviceRadiusKm: int.parse(_serviceRadiusKm.text.trim()),
    );

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(body);
    } catch (e) {
      // Os outros erros já foram mostrados pelo ecrã
      if (e is ApiError && mounted) {
        setState(() {
          _serverErrors = serverFieldErrors(e);
          _generalError = e.status == 400 && e.errors == null ? e.detail : null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final loadedCategories = categories.value;

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Coluna e não ListView: todos os campos existem sempre e são validados, mesmo fora do ecrã
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle('Sobre si'),
            LabeledField(
              label: 'Apresentação',
              child: TextFormField(
                key: const ValueKey('introduction'),
                controller: _introduction,
                decoration: const InputDecoration(
                  hintText:
                      'Ex.: Canalizador com 10 anos de experiência em '
                      'reparações domésticas.',
                  hintMaxLines: 3,
                ),
                minLines: 3,
                maxLines: 6,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                validator: all([
                  notEmpty('Indique a apresentação.'),
                  maxLength(
                    1000,
                    'A apresentação tem, no máximo, 1000 caracteres.',
                  ),
                ]),
                forceErrorText: _serverErrors['introduction'],
                onChanged: (_) => _clearServerError('introduction'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledField(
              label: 'Contactos',
              child: TextFormField(
                key: const ValueKey('contactDetails'),
                controller: _contactDetails,
                decoration: const InputDecoration(
                  hintText: 'Ex.: 912 345 678 (dias úteis, 8h–19h)',
                ),
                minLines: 2,
                maxLines: 5,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                validator: all([
                  notEmpty('Indique os contactos.'),
                  maxLength(
                    500,
                    'Os contactos têm, no máximo, 500 caracteres.',
                  ),
                ]),
                forceErrorText: _serverErrors['contactDetails'],
                onChanged: (_) => _clearServerError('contactDetails'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledField(
              label: 'Experiência profissional',
              child: TextFormField(
                key: const ValueKey('experience'),
                controller: _experience,
                decoration: const InputDecoration(
                  hintText:
                      'Ex.: 10 anos em canalização; reparação de fugas e '
                      'substituição de torneiras.',
                  hintMaxLines: 3,
                ),
                minLines: 3,
                maxLines: 6,
                maxLength: 2000,
                keyboardType: TextInputType.multiline,
                validator: all([
                  notEmpty('Indique a experiência.'),
                  maxLength(
                    2000,
                    'A experiência tem, no máximo, 2000 caracteres.',
                  ),
                ]),
                forceErrorText: _serverErrors['experience'],
                onChanged: (_) => _clearServerError('experience'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _SectionTitle('Categorias'),
            switch (categories) {
              AsyncValue(value: final items?) => FormField<void>(
                key: const ValueKey('serviceCategoryIds'),
                validator: (_) => _activeSelection(items).isEmpty
                    ? 'Indique pelo menos uma categoria de serviços.'
                    : null,
                forceErrorText: _serverErrors['serviceCategoryIds'],
                builder: (field) => CategorySelector(
                  categories: items,
                  selected: _activeSelection(items),
                  enabled: !_submitting,
                  errorText: field.errorText,
                  onChanged: _handleCategoriesChanged,
                ),
              ),
              AsyncValue(:final error?) => ErrorStateView(
                error: error,
                onRetry: () => ref.invalidate(categoriesProvider),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('Área de atuação'),
            LabeledField(
              label: 'Morada',
              child: TextFormField(
                key: const ValueKey('address'),
                controller: _address,
                decoration: InputDecoration(
                  hintText: 'Rua, número, localidade',
                  // Erro da posição do dispositivo: não impede o envio de uma morada escrita à mão
                  errorText: _positionError,
                  errorMaxLines: 3,
                ),
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                validator: all([
                  notEmpty('Indique a morada.'),
                  maxLength(255, 'A morada tem, no máximo, 255 caracteres.'),
                ]),
                forceErrorText: _serverErrors['address'],
                onChanged: (_) => _handleAddressChanged(),
              ),
            ),
            CurrentPositionButton(
              controller: _address,
              onError: _handlePositionError,
              enabled: !_submitting,
            ),
            const SizedBox(height: AppSpacing.sm),
            LabeledField(
              label: 'Raio de atuação (km)',
              child: TextFormField(
                key: const ValueKey('serviceRadiusKm'),
                controller: _serviceRadiusKm,
                decoration: const InputDecoration(errorMaxLines: 2),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: all([
                  notEmpty('Indique o raio de atuação.'),
                  intRange(
                    1,
                    100,
                    'O raio de atuação tem de estar entre 1 e 100 km.',
                  ),
                ]),
                forceErrorText: _serverErrors['serviceRadiusKm'],
                onChanged: (_) => _clearServerError('serviceRadiusKm'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FormErrorText(_generalError),
            FilledButton(
              // Sem as categorias carregadas não há como validar nem enviar a escolha
              onPressed: _submitting || loadedCategories == null
                  ? null
                  : () => _handleSubmit(loadedCategories),
              child: Text(widget.submitLabel),
            ),
            if (widget.onCancel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _submitting ? null : widget.onCancel,
                child: const Text('Cancelar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
