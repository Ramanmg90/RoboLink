import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_store.dart';
import '../../data/models/history_event.dart';

class HistoryState {
  const HistoryState({this.events = const [], this.loadError});
  final List<HistoryEvent> events; // newest first
  final String? loadError;
}

final historyProvider =
    NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() => _load();

  HistoryState _load() {
    try {
      return HistoryState(events: ref.read(storeProvider).loadHistory());
    } catch (_) {
      return const HistoryState(loadError: 'خواندن تاریخچهٔ ذخیره‌شده ممکن نشد.');
    }
  }

  void reload() => state = _load();

  void add(HistoryType type, String message, {String? deviceName}) {
    final now = DateTime.now();
    final event = HistoryEvent(
      id: now.microsecondsSinceEpoch.toString(),
      type: type,
      message: message,
      time: now,
      deviceName: deviceName,
    );
    final list = [event, ...state.events]
        .take(LocalStore.maxHistory)
        .toList(growable: false);
    state = HistoryState(events: list);
    unawaited(ref.read(storeProvider).saveHistory(list));
  }

  Future<void> clear() async {
    state = const HistoryState();
    await ref.read(storeProvider).clearHistory();
  }
}
