import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/glass_theme.dart';
import '../../data/models/connection_status.dart';
import '../../data/models/relay_state.dart';
import 'status_badge.dart';

extension RelayLabels on RelayState {
  String get label => switch (this) {
        RelayState.on => 'روشن',
        RelayState.off => 'خاموش',
        RelayState.unknown => 'نامشخص',
      };

  Color colorOf(GlassTheme g) => switch (this) {
        RelayState.on => AppColors.green,
        RelayState.off => AppColors.red,
        RelayState.unknown => g.textSecondary,
      };
}

extension ConnectionLabels on ConnectionStatus {
  String get label => switch (this) {
        ConnectionStatus.online => 'متصل',
        ConnectionStatus.offline => 'قطع',
        ConnectionStatus.checking => 'در حال بررسی',
        ConnectionStatus.unknown => 'نامشخص',
      };

  Color colorOf(GlassTheme g) => switch (this) {
        ConnectionStatus.online => AppColors.green,
        ConnectionStatus.offline => AppColors.red,
        ConnectionStatus.checking => AppColors.yellow,
        ConnectionStatus.unknown => g.textSecondary,
      };
}

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status});
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return StatusBadge(
      label: status.label,
      color: status.colorOf(g),
      busy: status == ConnectionStatus.checking,
      icon: switch (status) {
        ConnectionStatus.online => Icons.wifi_rounded,
        ConnectionStatus.offline => Icons.wifi_off_rounded,
        _ => null,
      },
    );
  }
}

class RelayBadge extends StatelessWidget {
  const RelayBadge({super.key, required this.state});
  final RelayState state;

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return StatusBadge(
      label: 'رله: ${state.label}',
      color: state.colorOf(g),
      icon: Icons.power_settings_new_rounded,
    );
  }
}
