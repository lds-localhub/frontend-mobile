import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/api/session.dart';
import 'package:localhub/config/api_config.dart';
import 'package:localhub/data/auth.dart';
import 'package:localhub/models/user.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';

/// Início de sessão de Cliente ou de Prestador (M03), com o contacto de
/// suporte e a mensagem do registo ou da sessão terminada.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.notice});

  /// Mensagem vinda do registo («Conta criada. Inicie sessão.»).
  final String? notice;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  bool _forgotOpen = false;
  String? _generalError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      // Com sucesso, o router leva ao início do papel
      await login(
        LoginInput(email: _email.text.trim(), password: _password.text),
      );
    } catch (e) {
      // Todos os erros do login ficam no formulário, incluindo o 401 e a recusa do Administrador
      if (mounted) {
        setState(() {
          _serverErrors = e is ApiError ? serverFieldErrors(e) : {};
          _generalError = e is ApiError && e.errors != null
              ? null
              : getErrorMessage(e);
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
    final theme = Theme.of(context);
    final notice =
        widget.notice ??
        (Session.instance.expired
            ? 'A sua sessão terminou. Inicie sessão novamente.'
            : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sessão')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (notice != null) ...[
                _Banner(icon: Icons.info_outline, text: notice),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                'Entre com o e-mail e a palavra-passe da sua conta.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                key: const ValueKey('email'),
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: notEmpty('O e-mail é obrigatório.'),
                forceErrorText: _serverErrors['email'],
                onChanged: (_) => _clearServerError('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                key: const ValueKey('password'),
                controller: _password,
                decoration: const InputDecoration(labelText: 'Palavra-passe'),
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                validator: notEmpty('A palavra-passe é obrigatória.'),
                forceErrorText: _serverErrors['password'],
                onChanged: (_) => _clearServerError('password'),
                onFieldSubmitted: (_) => _submitting ? null : _handleSubmit(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _forgotOpen = !_forgotOpen),
                  child: const Text('Esqueci-me da palavra-passe'),
                ),
              ),
              // Não há recuperação pelo sistema: a administração redefine a palavra-passe
              if (_forgotOpen) ...[
                const _Banner(
                  icon: Icons.key_outlined,
                  text:
                      'Para recuperar o acesso, contacte $supportEmail a '
                      'partir do endereço de e-mail registado na conta.',
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.sm),
              FormErrorText(_generalError),
              FilledButton(
                onPressed: _submitting ? null : _handleSubmit,
                child: const Text('Entrar'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => context.pushReplacement('/registar'),
                child: const Text('Criar conta'),
              ),
              const SizedBox(height: AppSpacing.md),
              const _Banner(
                icon: Icons.mail_outline,
                text:
                    'Precisa de ajuda com a sua conta? Contacte o suporte: '
                    '$supportEmail',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
