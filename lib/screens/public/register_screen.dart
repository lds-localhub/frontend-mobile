import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Registo de uma conta de Cliente ou de Prestador de Serviços (M02).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _role = Role.client;
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  String? _generalError;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Ao escrever num campo, o erro do backend desse campo deixa de valer
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

    final body = RegisterInput(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      role: _role,
    );

    setState(() => _submitting = true);
    try {
      await register(body);
      if (mounted) {
        context.go('/login', extra: 'Conta criada. Inicie sessão.');
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

    return Scaffold(
      appBar: AppBar(title: const Text('Registar conta')),
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
                Text('Criar conta', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Leva menos de um minuto.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                LabeledField(
                  label: 'Nome',
                  child: TextFormField(
                    key: const ValueKey('name'),
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: all([
                      notEmpty('Indique o nome.'),
                      maxLength(100, 'O nome é demasiado longo.'),
                    ]),
                    forceErrorText: _serverErrors['name'],
                    onChanged: (_) => _clearServerError('name'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                LabeledField(
                  label: 'E-mail',
                  child: TextFormField(
                    key: const ValueKey('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: all([
                      notEmpty('Indique o e-mail.'),
                      maxLength(254, 'O e-mail é demasiado longo.'),
                      email('O e-mail não é válido.'),
                    ]),
                    forceErrorText: _serverErrors['email'],
                    onChanged: (_) => _clearServerError('email'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                LabeledField(
                  label: 'Palavra-passe',
                  child: TextFormField(
                    key: const ValueKey('password'),
                    controller: _password,
                    decoration: const InputDecoration(
                      helperText:
                          'Mínimo 8 caracteres, com letras e algarismos.',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: all([
                      notEmpty('Indique a palavra-passe.'),
                      password(),
                    ]),
                    forceErrorText: _serverErrors['password'],
                    onChanged: (_) => _clearServerError('password'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Tipo de conta', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<Role>(
                  segments: const [
                    ButtonSegment(value: Role.client, label: Text('Cliente')),
                    ButtonSegment(
                      value: Role.provider,
                      label: Text('Prestador de Serviços'),
                    ),
                  ],
                  selected: {_role},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => setState(() {
                    _role = selection.first;
                    _serverErrors = {..._serverErrors}..remove('role');
                  }),
                ),
                FormErrorText(_serverErrors['role']),
                const SizedBox(height: AppSpacing.xl),
                FormErrorText(_generalError),
                FilledButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  child: const Text('Criar conta'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.pushReplacement('/login'),
                  child: const Text('Já tenho conta — Iniciar sessão'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
