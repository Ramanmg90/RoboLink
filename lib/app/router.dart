import 'package:go_router/go_router.dart';

import '../features/connection/add_device_screen.dart';
import '../features/device_control/device_control_screen.dart';
import '../features/devices/devices_screen.dart';
import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

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
        GoRoute(path: '/device', builder: (_, __) => const DeviceControlScreen()),
        GoRoute(path: '/devices/add', builder: (_, __) => const AddDeviceScreen()),
        GoRoute(
          path: '/devices/edit/:id',
          builder: (_, state) =>
              AddDeviceScreen(editId: state.pathParameters['id']),
        ),
      ],
    );
