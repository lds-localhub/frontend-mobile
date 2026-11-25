import 'package:material_ui/material_ui.dart';

import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/utils/validators.dart';
import 'package:localhub/widgets/categories/category_dropdown.dart';
import 'package:localhub/widgets/location/address_field.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

import 'create_service_screen.dart';

/// Data UTC de hoje (`AAAA-MM-DD`), a que o backend usa para validar as datas.
String _todayUtc() => DateTime.now().toUtc().toIso8601String().substring(0, 10);

/// Separador «Detalhes» do criar serviço: categoria (limitada às categorias
/// dos Prestadores selecionados), título, descrição, local de realização e
/// disponibilidade (data única ou intervalo).
///
/// Os valores são do ecrã; as alterações voltam por callbacks.
class ServiceDetailsTab extends StatelessWidget {
  const ServiceDetailsTab({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.serviceCategoryId,
    required this.onlyCategoryIds,
    required this.dateMode,
    required this.startDate,
    required this.endDate,
    required this.serverErrors,
    required this.positionError,
    required this.onCategoryChanged,
    required this.onDateModeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onFieldChanged,
    required this.onPositionError,
    this.enabled = true,
  });

  final TextEditingController title;
  final TextEditingController description;
  final TextEditingController location;
  final int? serviceCategoryId;
  final List<int>? onlyCategoryIds;
  final DateMode dateMode;
  final String? startDate;
  final String? endDate;
  final Map<String, String> serverErrors;
  final String? positionError;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<DateMode> onDateModeChanged;
  final ValueChanged<String> onStartDateChanged;
  final ValueChanged<String> onEndDateChanged;

  /// Um campo foi alterado: o erro do backend desse campo deixa de valer.
  final ValueChanged<String> onFieldChanged;
  final ValueChanged<String?> onPositionError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormField<void>(
          validator: (_) =>
              serviceCategoryId == null ? 'Escolha a categoria.' : null,
          forceErrorText: serverErrors['serviceCategoryId'],
          builder: (field) => CategoryDropdown(
            value: serviceCategoryId,
            onlyIds: onlyCategoryIds,
            helperText: onlyCategoryIds == null
                ? null
                : 'Só categorias dos Prestadores selecionados.',
            errorText: field.errorText,
            enabled: enabled,
            onChanged: (id) {
              onCategoryChanged(id);
              onFieldChanged('serviceCategoryId');
              field.didChange(null);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        LabeledField(
          label: 'Título',
          child: TextFormField(
            key: const ValueKey('title'),
            controller: title,
            enabled: enabled,
            decoration: const InputDecoration(helperText: '1 a 100 caracteres'),
            maxLength: 100,
            validator: all([
              notEmpty('Indique o título.'),
              maxLength(100, 'O título tem, no máximo, 100 caracteres.'),
            ]),
            forceErrorText: serverErrors['title'],
            onChanged: (_) => onFieldChanged('title'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        LabeledField(
          label: 'Descrição do serviço',
          child: TextFormField(
            key: const ValueKey('description'),
            controller: description,
            enabled: enabled,
            decoration: const InputDecoration(
              helperText: '1 a 1000 caracteres',
            ),
            minLines: 3,
            maxLines: 6,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
            validator: all([
              notEmpty('Indique a descrição.'),
              maxLength(1000, 'A descrição tem, no máximo, 1000 caracteres.'),
            ]),
            forceErrorText: serverErrors['description'],
            onChanged: (_) => onFieldChanged('description'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AddressField(
          label: 'Local de realização',
          requiredMessage: 'Indique o local de realização.',
          maxLengthMessage: 'O local tem, no máximo, 255 caracteres.',
          controller: location,
          positionError: positionError,
          serverError: serverErrors['location'],
          onChanged: () => onFieldChanged('location'),
          onPositionError: onPositionError,
          enabled: enabled,
        ),
        const SizedBox(height: AppSpacing.md),
        LabeledField(
          label: 'Disponibilidade pretendida',
          child: SegmentedButton<DateMode>(
            segments: const [
              ButtonSegment(value: DateMode.single, label: Text('Data única')),
              ButtonSegment(
                value: DateMode.range,
                label: Text('Intervalo de datas'),
              ),
            ],
            selected: {dateMode},
            showSelectedIcon: false,
            onSelectionChanged: enabled
                ? (selection) => onDateModeChanged(selection.first)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DateField(
                key: const ValueKey('requestedStartDate'),
                label: dateMode == DateMode.range ? 'De' : null,
                value: startDate,
                enabled: enabled,
                serverError: serverErrors['requestedStartDate'],
                validator: () {
                  final start = startDate;
                  if (start == null) {
                    return 'Indique a data.';
                  }
                  return start.compareTo(_todayUtc()) < 0
                      ? 'A data não pode ser anterior a hoje.'
                      : null;
                },
                onChanged: (day) {
                  onStartDateChanged(day);
                  onFieldChanged('requestedStartDate');
                },
              ),
            ),
            if (dateMode == DateMode.range) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DateField(
                  key: const ValueKey('requestedEndDate'),
                  label: 'Até',
                  value: endDate,
                  enabled: enabled,
                  serverError: serverErrors['requestedEndDate'],
                  validator: () {
                    final start = startDate;
                    final end = endDate;
                    if (end == null) {
                      return 'Indique a data final.';
                    }
                    return start != null && end.compareTo(start) < 0
                        ? 'A data final não pode ser anterior à data inicial.'
                        : null;
                  },
                  onChanged: (day) {
                    onEndDateChanged(day);
                    onFieldChanged('requestedEndDate');
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Datas iguais ou posteriores a hoje',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Data escolhida no calendário, validada com as outras ao enviar.
class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.label,
    required this.value,
    required this.validator,
    required this.onChanged,
    required this.enabled,
    this.serverError,
  });

  final String? label;
  final String? value;
  final String? Function() validator;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? serverError;

  static String _toApiDay(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _handlePressed(
    BuildContext context,
    FormFieldState<void> field,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = value == null ? null : DateTime.parse(value!);
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    if (picked != null) {
      onChanged(_toApiDay(picked));
      field.didChange(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final day = value;
    final label = this.label;

    final field = FormField<void>(
      validator: (_) => validator(),
      forceErrorText: serverError,
      builder: (field) => InkWell(
        borderRadius: BorderRadius.circular(AppRadius.field),
        onTap: enabled ? () => _handlePressed(context, field) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            errorText: field.errorText,
            errorMaxLines: 3,
            enabled: enabled,
          ),
          child: Text(
            day == null ? 'dd/mm/aaaa' : formatDay(day),
            style: day == null
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );

    return label == null ? field : LabeledField(label: label, child: field);
  }
}
