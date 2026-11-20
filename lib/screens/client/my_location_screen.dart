import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/data/locations.dart';
import 'package:localhub/models/location.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/location/current_position_button.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/messages.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Localização do Cliente, por endereço ou pela posição do dispositivo (M15).
class MyLocationScreen extends ConsumerStatefulWidget {
  const MyLocationScreen({super.key});

  @override
  ConsumerState<MyLocationScreen> createState() => _MyLocationScreenState();
}

class _MyLocationScreenState extends ConsumerState<MyLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address;
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  String? _generalError;
  String? _positionError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Sem localização registada, o campo começa vazio
    _address = TextEditingController(
      text: ref.read(meProvider).value?.address ?? '',
    );
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _handleAddressChanged() {
    if (_serverErrors.containsKey('address') || _positionError != null) {
      setState(() {
        _serverErrors = {..._serverErrors}..remove('address');
        _positionError = null;
      });
    }
  }

  // Usar a posição substitui a morada escrita: o erro do backend sobre ela deixa de valer
  void _handlePositionError(String? error) => setState(() {
    _positionError = error;
    _serverErrors = {..._serverErrors}..remove('address');
  });

  Future<void> _handleSubmit() async {
    setState(() {
      _serverErrors = {};
      _generalError = null;
      _autovalidateMode = AutovalidateMode.always;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await setLocation(
        ref,
        body: LocationInput(address: _address.text.trim()),
      );
      showMessage('Localização atualizada.');
      // A dica do campo passa a dizer que esta é a localização registada
      try {
        await ref.read(meProvider.future);
      } catch (_) {
        // A localização já foi guardada: uma falha a recarregar o utilizador não é um erro do envio
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      if (e is ApiError && (e.errors != null || e.status == 400)) {
        setState(() {
          _serverErrors = serverFieldErrors(e);
          _generalError = e.errors == null ? e.detail : null;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAddress = ref.watch(meProvider).value?.address != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Localização')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'A minha localização',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LabeledField(
                                label: 'Endereço',
                                child: TextFormField(
                                  key: const ValueKey('address'),
                                  controller: _address,
                                  decoration: InputDecoration(
                                    hintText: 'Ex.: Rua de Santa Catarina 100',
                                    // Erro da posição do dispositivo: não impede
                                    // o envio de um endereço escrito à mão
                                    errorText: _positionError,
                                    errorMaxLines: 3,
                                  ),
                                  keyboardType: TextInputType.streetAddress,
                                  validator: all([
                                    notEmpty('Indique o endereço.'),
                                    maxLength(
                                      255,
                                      'O endereço tem, no máximo, 255 '
                                      'caracteres.',
                                    ),
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
                              Text(
                                hasAddress
                                    ? 'É a sua localização registada. Altere '
                                          'e guarde para a substituir.'
                                    : 'Ainda não definiu a sua localização. '
                                          'Indique um endereço e guarde.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormErrorText(_generalError),
                    FilledButton(
                      onPressed: _submitting ? null : _handleSubmit,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
