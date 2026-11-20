import 'package:material_ui/material_ui.dart';

import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/location/current_position_button.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Campo da morada, obrigatório e com 255 caracteres no máximo, com
/// «Usar a minha posição atual» por baixo (M15, M27 e M27b).
///
/// O erro da posição do dispositivo ([positionError]) aparece junto ao campo,
/// mas não impede o envio de uma morada escrita à mão; o erro do backend
/// ([serverError]) impede, até a morada ser alterada.
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.label,
    required this.requiredMessage,
    required this.maxLengthMessage,
    required this.controller,
    required this.onChanged,
    required this.onPositionError,
    this.positionError,
    this.serverError,
    this.focusNode,
    this.textInputAction,
    this.enabled = true,
  });

  final String label;
  final String requiredMessage;
  final String maxLengthMessage;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final ValueChanged<String?> onPositionError;
  final String? positionError;
  final String? serverError;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledField(
          label: label,
          child: TextFormField(
            key: const ValueKey('address'),
            focusNode: focusNode,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Rua, número, localidade',
              errorText: positionError,
              errorMaxLines: 3,
            ),
            keyboardType: TextInputType.streetAddress,
            textInputAction: textInputAction,
            validator: all([
              notEmpty(requiredMessage),
              maxLength(255, maxLengthMessage),
            ]),
            forceErrorText: serverError,
            onChanged: (_) => onChanged(),
          ),
        ),
        CurrentPositionButton(
          controller: controller,
          onError: onPositionError,
          enabled: enabled,
        ),
      ],
    );
  }
}
