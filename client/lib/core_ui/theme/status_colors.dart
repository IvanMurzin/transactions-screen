import 'package:flutter/material.dart';

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({required this.success, required this.error, required this.muted});

  final Color success;

  final Color error;

  final Color muted;

  factory StatusColors.light(ColorScheme scheme) => StatusColors(
    success: const Color(0xFF1B873F),
    error: scheme.error,
    muted: scheme.onSurfaceVariant,
  );

  factory StatusColors.dark(ColorScheme scheme) => StatusColors(
    success: const Color(0xFF3DD68C),
    error: scheme.error,
    muted: scheme.onSurfaceVariant,
  );

  @override
  StatusColors copyWith({Color? success, Color? error, Color? muted}) => StatusColors(
    success: success ?? this.success,
    error: error ?? this.error,
    muted: muted ?? this.muted,
  );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light(Theme.of(this).colorScheme);
}
