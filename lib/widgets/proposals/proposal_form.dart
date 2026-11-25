import 'package:flutter/foundation.dart' show AsyncValueSetter;
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/proposal.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Formulário de apresentar proposta (valor, condições e observação), comum à
/// resposta a uma solicitação direta e à proposta a um serviço aberto.
///
/// Os valores fora dos limites são indicados junto ao campo, sem pedido. O
/// ecrã faz o pedido em [onSubmit] e trata os erros que não são do formulário;
/// os erros com `errors` têm de voltar a ser lançados, para o formulário os pôr
/// junto aos campos. Com [onDecline], mostra também «Recusar solicitação».
class ProposalForm extends StatefulWidget {
  const ProposalForm({
    super.key,
    required this.onSubmit,
    this.onDecline,
    this.enabled = true,
  });

  final AsyncValueSetter<ProposalInput> onSubmit;
  final VoidCallback? onDecline;
  final bool enabled;

  @override
  State<ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends State<ProposalForm> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _conditions = TextEditingController();
  final _obs = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _serverErrors = <String, String>{};
  String? _generalError;
  bool _submitting = false;

  @override
  void dispose() {
    _amount.dispose();
    _conditions.dispose();
    _obs.dispose();
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

    final obs = _obs.text.trim();
    final body = ProposalInput(
      amount: parseAmount(_amount.text)!,
      conditions: _conditions.text.trim(),
      obs: obs.isEmpty ? null : obs,
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
    final theme = Theme.of(context);
    final canSubmit = widget.enabled && !_submitting;
    final danger = theme.colorScheme.error;

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Apresentar proposta',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledField(
                    label: 'Valor (€)',
                    child: TextFormField(
                      key: const ValueKey('amount'),
                      controller: _amount,
                      enabled: canSubmit,
                      decoration: const InputDecoration(
                        helperText:
                            'Obrigatório · maior que 0 e até 100 000,00 €',
                        errorMaxLines: 2,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: all([notEmpty('Indique o valor.'), amount()]),
                      forceErrorText: _serverErrors['amount'],
                      onChanged: (_) => _clearServerError('amount'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledField(
                    label: 'Condições',
                    child: TextFormField(
                      key: const ValueKey('conditions'),
                      controller: _conditions,
                      enabled: canSubmit,
                      decoration: const InputDecoration(
                        helperText: 'Obrigatório · 1 a 1000 caracteres',
                        errorMaxLines: 2,
                      ),
                      minLines: 3,
                      maxLines: 6,
                      keyboardType: TextInputType.multiline,
                      validator: all([
                        notEmpty('Indique as condições.'),
                        maxLength(
                          1000,
                          'As condições têm, no máximo, 1000 caracteres.',
                        ),
                      ]),
                      forceErrorText: _serverErrors['conditions'],
                      onChanged: (_) => _clearServerError('conditions'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LabeledField(
                    label: 'Observação',
                    child: TextFormField(
                      key: const ValueKey('obs'),
                      controller: _obs,
                      enabled: canSubmit,
                      decoration: const InputDecoration(
                        helperText: 'Opcional · até 500 caracteres',
                        errorMaxLines: 2,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      validator: maxLength(
                        500,
                        'As observações têm, no máximo, 500 caracteres.',
                      ),
                      forceErrorText: _serverErrors['obs'],
                      onChanged: (_) => _clearServerError('obs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FormErrorText(_generalError),
          FilledButton(
            onPressed: canSubmit ? _handleSubmit : null,
            child: const Text('Enviar proposta'),
          ),
          if (widget.onDecline != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: danger,
                side: BorderSide(color: danger.withValues(alpha: 0.4)),
              ),
              onPressed: canSubmit ? widget.onDecline : null,
              child: const Text('Recusar solicitação'),
            ),
          ],
        ],
      ),
    );
  }
}
