import 'package:flutter/material.dart';

extension ColorAlpha on Color {
  /// Returns this colour with the given opacity (0..1).
  Color a(double opacity) => withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
}
