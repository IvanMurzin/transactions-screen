import 'package:flutter/material.dart';

import 'package:template_app/core_ui/theme/ds_theme.dart';

/// Tiny indeterminate loader used by buttons, cards, and skeleton states.
///
/// Sized via [size]; defaults to a comfortable 24×24 dot. Color falls back
/// to the design-system primary tone when not specified.
class DSLoader extends StatelessWidget {
  const DSLoader({super.key, this.size, this.strokeWidth = 2.5, this.color});

  final double? size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final spacing = context.dsSpacing;
    final dimension = size ?? spacing.s24;
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colors.primary),
      ),
    );
  }
}
