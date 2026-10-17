import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.timeoutSeconds = defaultTimeout,
    this.autoRefresh = true,
    this.haptics = true,
    this.language = 'fa',
  });

  static const minTimeout = 2;
  static const maxTimeout = 15;
  static const defaultTimeout = 5;

  final ThemeMode themeMode;
  final int timeoutSeconds;
  final bool autoRefresh;
  final bool haptics;
  final String language;

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? timeoutSeconds,
    bool? autoRefresh,
    bool? haptics,
    String? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      timeoutSeconds:
          (timeoutSeconds ?? this.timeoutSeconds).clamp(minTimeout, maxTimeout),
      autoRefresh: autoRefresh ?? this.autoRefresh,
      haptics: haptics ?? this.haptics,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'timeoutSeconds': timeoutSeconds,
        'autoRefresh': autoRefresh,
        'haptics': haptics,
        'language': language,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final mode = ThemeMode.values.asNameMap()[json['themeMode']] ?? ThemeMode.dark;
    return const AppSettings().copyWith(
      themeMode: mode,
      timeoutSeconds: json['timeoutSeconds'] as int?,
      autoRefresh: json['autoRefresh'] as bool?,
      haptics: json['haptics'] as bool?,
      language: json['language'] as String?,
    );
  }
}
