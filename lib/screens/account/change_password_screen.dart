import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/messages.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Alteração da própria palavra-passe (M19), também da temporária atribuída
/// pela administração.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  String? _generalError;
  bool _submitting = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _clearServerError(String field) {
    if (_serverErrors.containsKey(field)) {
      setState(() => _serverErrors = {..._serverErrors}..remove(field));
    }
  }

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
      await changePassword(
        ChangePasswordInput(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
        ),
      );
      if (mounted) {
        // Campos limpos e sem erros: o formulário volta ao estado inicial
        _formKey.currentState!.reset();
        _currentPassword.clear();
        _newPassword.clear();
        _confirmation.clear();
        setState(() => _autovalidateMode = AutovalidateMode.disabled);
        showMessage('Palavra-passe alterada.');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar palavra-passe')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            // Coluna e não ListView: todos os campos existem sempre e são validados, mesmo fora do ecrã
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Indique a palavra-passe atual e a nova palavra-passe. As '
                  'sessões iniciadas noutros dispositivos são terminadas; esta '
                  'sessão mantém-se.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                LabeledField(
                  label: 'Palavra-passe atual',
                  child: TextFormField(
                    key: const ValueKey('currentPassword'),
                    controller: _currentPassword,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    validator: notEmpty('Indique a palavra-passe atual.'),
                    forceErrorText: _serverErrors['currentPassword'],
                    onChanged: (_) => _clearServerError('currentPassword'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                LabeledField(
                  label: 'Nova palavra-passe',
                  child: TextFormField(
                    key: const ValueKey('newPassword'),
                    controller: _newPassword,
                    decoration: const InputDecoration(
                      helperText:
                          'Mínimo de 8 caracteres, com pelo menos uma letra e um '
                          'algarismo.',
                      helperMaxLines: 2,
                    ),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    validator: all([
                      notEmpty('Indique a nova palavra-passe.'),
                      password(),
                    ]),
                    forceErrorText: _serverErrors['newPassword'],
                    onChanged: (_) => _clearServerError('newPassword'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                LabeledField(
                  label: 'Confirmar nova palavra-passe',
                  child: TextFormField(
                    key: const ValueKey('confirmation'),
                    controller: _confirmation,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    // Só o telemóvel verifica a confirmação: não é enviada ao backend
                    validator: all([
                      notEmpty('Confirme a nova palavra-passe.'),
                      (value) => value == _newPassword.text ? null : 'A confirmação não corresponde à nova palavra-passe.',
                    ]),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FormErrorText(_generalError),
                FilledButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
