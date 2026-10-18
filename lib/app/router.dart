import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/connection/add_device_screen.dart';
import '../features/device_control/device_control_screen.dart';
import '../features/devices/devices_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

/// Soft "rise and fade" transition for pages pushed above the tab shell.
CustomTransitionPage<void> _risePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.of(context).disableAnimations) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

GoRouter createRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/devices', builder: (_, __) => const DevicesScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
            ]),
          ],
        ),
        GoRoute(
          path: '/device',
          pageBuilder: (_, state) =>
              _risePage(state, const DeviceControlScreen()),
        ),
        GoRoute(
          path: '/devices/add',
          pageBuilder: (_, state) => _risePage(state, const AddDeviceScreen()),
        ),
        GoRoute(
          path: '/devices/edit/:id',
          pageBuilder: (_, state) => _risePage(
            state,
            AddDeviceScreen(editId: state.pathParameters['id']),
          ),
        ),
        GoRoute(
          path: '/setup',
          pageBuilder: (_, state) => _risePage(state, const OnboardingScreen()),
        ),
      ],
    );
