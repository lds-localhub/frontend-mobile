import 'package:material_ui/material_ui.dart';

/// Cinco estrelas de uma classificação de 1 a 5, preenchidas até [rating]
/// (arredondada à unidade).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 18});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filled = rating.round();

    return Semantics(
      label: '${rating.round()} de 5 estrelas',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var star = 1; star <= 5; star++)
            Icon(
              Icons.star_rounded,
              size: size,
              color: star <= filled ? colors.tertiary : colors.outlineVariant,
            ),
        ],
      ),
    );
  }
}
