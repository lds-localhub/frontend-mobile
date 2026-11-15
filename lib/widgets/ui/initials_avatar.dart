import 'package:material_ui/material_ui.dart';

/// Iniciais do nome (primeira e última palavra) num círculo.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 28});

  final String name;
  final double radius;

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first.isEmpty ? '' : words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      child: Text(
        _initials,
        style: TextStyle(fontSize: radius * 0.6, fontWeight: FontWeight.w700),
      ),
    );
  }
}
