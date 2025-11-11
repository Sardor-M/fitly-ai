import 'package:flutter/material.dart';

/**
 * This class is used to display the brand logo.
 * It is also used to get the brand logo from the json.
 * It is also used to convert the brand logo to json.
 */
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 72,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    return Text.rich(
      TextSpan(
        text: 'FIT',
        style: theme.textTheme.displaySmall?.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: 6,
          color: color,
        ),
        children: [
          TextSpan(
            text: ':',
            style: TextStyle(
              color: theme.colorScheme.primary,
            ),
          ),
          TextSpan(
            text: 'LY',
            style: TextStyle(color: color),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

