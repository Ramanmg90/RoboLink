import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';

extension AppAccentStyle on AppAccent {
  String get label => switch (this) {
        AppAccent.orange => 'نارنجی',
        AppAccent.blue => 'آبی',
        AppAccent.violet => 'بنفش',
      };

  Color get color => switch (this) {
        AppAccent.orange => const Color(0xFFFF8A24),
        AppAccent.blue => const Color(0xFF3D9BFF),
        AppAccent.violet => const Color(0xFF9B6BFF),
      };

  /// Lighter companion used for gradients.
  Color get soft => switch (this) {
        AppAccent.orange => const Color(0xFFFFB35C),
        AppAccent.blue => const Color(0xFF7CC0FF),
        AppAccent.violet => const Color(0xFFC1A3FF),
      };
}
