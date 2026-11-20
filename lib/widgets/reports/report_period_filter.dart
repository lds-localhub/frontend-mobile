import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/report.dart';
import 'package:localhub/theme/app_theme.dart';
import 'package:localhub/utils/format.dart';
import 'package:localhub/widgets/ui/labeled_field.dart';

/// Período dos relatórios: data inicial e final opcionais, aplicadas só com
/// «Aplicar período» e verificadas antes do pedido.
class ReportPeriodFilter extends StatefulWidget {
  const ReportPeriodFilter({
    super.key,
    required this.value,
    required this.onApply,
  });

  final ReportParams value;
  final ValueChanged<ReportParams> onApply;

  @override
  State<ReportPeriodFilter> createState() => _ReportPeriodFilterState();
}

class _ReportPeriodFilterState extends State<ReportPeriodFilter> {
  late String? _startDate = widget.value.startDate;
  late String? _endDate = widget.value.endDate;
  String? _dateError;

  // Ao mudar uma data, o erro das datas trocadas deixa de valer até ao
  // próximo «Aplicar período»
  void _handleStartDateChanged(String? date) => setState(() {
    _startDate = date;
    _dateError = null;
  });

  void _handleEndDateChanged(String? date) => setState(() {
    _endDate = date;
    _dateError = null;
  });

  void _handleApplyPressed() {
    // As datas AAAA-MM-DD comparam-se como texto; o backend recusa o período trocado
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.compareTo(_endDate!) > 0) {
      setState(
        () => _dateError = 'A data final não pode ser anterior à data inicial.',
      );
      return;
    }
    setState(() => _dateError = null);
    widget.onApply((startDate: _startDate, endDate: _endDate));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LabeledField(
                label: 'Data inicial',
                child: _DateField(
                  key: const ValueKey('startDate'),
                  clearTooltip: 'Limpar data inicial',
                  value: _startDate,
                  onChanged: _handleStartDateChanged,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: LabeledField(
                label: 'Data final',
                child: _DateField(
                  key: const ValueKey('endDate'),
                  clearTooltip: 'Limpar data final',
                  value: _endDate,
                  errorText: _dateError,
                  onChanged: _handleEndDateChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: _handleApplyPressed,
          child: const Text('Aplicar período'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'O período considera a data de criação de cada serviço. '
          'Sem período, inclui toda a atividade.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Data escolhida no calendário (`AAAA-MM-DD`), com × para a limpar.
class _DateField extends StatelessWidget {
  const _DateField({
    super.key,
    required this.clearTooltip,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String clearTooltip;
  final String? value;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  Future<void> _handleTap(BuildContext context) async {
    final initial = value == null ? DateTime.now() : DateTime.parse(value!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked.toIso8601String().substring(0, 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InputDecorator(
        decoration: InputDecoration(
          errorText: errorText,
          errorMaxLines: 3,
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: clearTooltip,
                  onPressed: () => onChanged(null),
                ),
        ),
        child: Text(value == null ? '' : formatDay(value!)),
      ),
    );
  }
}
