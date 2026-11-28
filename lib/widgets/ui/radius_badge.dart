import 'package:material_ui/material_ui.dart';

import 'package:localhub/models/tone.dart';

import 'status_chip.dart';

/// Etiqueta «Dentro do raio» / «Fora do raio» de um resultado de pesquisa.
class RadiusBadge extends StatelessWidget {
  const RadiusBadge({super.key, required this.withinServiceRadius});

  final bool withinServiceRadius;

  @override
  Widget build(BuildContext context) {
    return withinServiceRadius
        ? const StatusChip(label: 'Dentro do raio', tone: Tone.success)
        : const StatusChip(label: 'Fora do raio', tone: Tone.warning);
  }
}
