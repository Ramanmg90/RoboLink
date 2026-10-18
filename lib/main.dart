import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/key_value_store.dart';
import 'core/storage/local_store.dart';

/// Shows the error text on screen instead of a blank/grey screen so a failure
/// can be read (or screenshotted) directly on the phone.
Widget _errorView(String text) => Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF2B0A0F),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFFFE3E6),
                fontSize: 12,
                height: 1.4,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (details) {
    final stack = details.stack?.toString().split('\n').take(12).join('\n') ?? '';
    return _errorView('RoboLink error:\n${details.exceptionAsString()}\n\n$stack');
  };

  try {
    final store = await FileKeyValueStore.open();
    runApp(
      ProviderScope(
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
        child: const RoboLinkApp(),
      ),
    );
  } catch (e, st) {
    runApp(_errorView('RoboLink startup error:\n$e\n\n$st'));
  }
}
