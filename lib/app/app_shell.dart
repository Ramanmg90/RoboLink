import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/glass_nav_bar.dart';
import '../core/widgets/neon_background.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _items = [
    NavItem('خانه', Icons.home_rounded),
    NavItem('دستگاه‌ها', Icons.devices_other_rounded),
    NavItem('تاریخچه', Icons.history_rounded),
    NavItem('تنظیمات', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: shell,
        bottomNavigationBar: GlassNavBar(
          currentIndex: shell.currentIndex,
          items: _items,
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
    );
  }
}
