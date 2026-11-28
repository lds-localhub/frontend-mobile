import 'package:flutter/foundation.dart' show AsyncValueSetter;
import 'package:material_ui/material_ui.dart';

import 'package:localhub/api/api_client.dart';
import 'package:localhub/models/service.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/errors.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/ui/form_error_text.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';
import 'package:localhub/widgets/ui/star_rating_field.dart';

/// Significado de cada classificação, ao lado das estrelas.
const ratingMeanings = {
  1: 'Muito insatisfeito',
  2: 'Insatisfeito',
  3: 'Razoável',
  4: 'Satisfeito',
  5: 'Muito satisfeito',
};

/// Formulário da avaliação: a classificação, obrigatória, e o comentário,
/// opcional, com as mesmas regras do backend. Não pede confirmação: submeter
/// já é a decisão.
///
/// O ecrã faz o pedido em [onSubmit] e trata os erros que não são do
/// formulário; os erros com `errors` têm de voltar a ser lançados, para o
/// formulário os pôr junto aos campos.
class ReviewForm extends StatefulWidget {
  const ReviewForm({
    super.key,
    required this.providerName,
    required this.onSubmit,
    required this.onCancel,
  });

  final String providerName;
  final AsyncValueSetter<ReviewInput> onSubmit;
  final VoidCallback onCancel;

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _comment = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  int? _rating;
  var _serverErrors = <String, String>{};
  String? _generalError;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
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

    final comment = _comment.text.trim();
    final body = ReviewInput(
      rating: _rating!,
      comment: comment.isEmpty ? null : comment,
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

    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Como correu o serviço com '),
                TextSpan(
                  text: widget.providerName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text:
                      '? A avaliação fica no perfil do Prestador e não pode '
                      'ser alterada depois.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledField(
            label: 'Classificação',
            child: FormField<int>(
              validator: (_) =>
                  _rating == null ? 'Escolha a classificação.' : null,
              forceErrorText: _serverErrors['rating'],
              builder: (field) => StarRatingField(
                value: _rating,
                meanings: ratingMeanings,
                errorText: field.errorText,
                enabled: !_submitting,
                onChanged: (rating) {
                  setState(() => _rating = rating);
                  _clearServerError('rating');
                  field.didChange(rating);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LabeledField(
            label: 'Comentário',
            child: TextFormField(
              key: const ValueKey('comment'),
              controller: _comment,
              enabled: !_submitting,
              decoration: const InputDecoration(
                helperText: 'Opcional · até 500 caracteres',
                errorMaxLines: 2,
              ),
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              validator: maxLength(
                500,
                'O comentário tem, no máximo, 500 caracteres.',
              ),
              forceErrorText: _serverErrors['comment'],
              onChanged: (_) => _clearServerError('comment'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FormErrorText(_generalError),
          FilledButton(
            onPressed: _submitting ? null : _handleSubmit,
            child: const Text('Submeter avaliação'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _submitting ? null : widget.onCancel,
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
