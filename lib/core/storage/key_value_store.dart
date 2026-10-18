import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Tiny synchronous-read key/value store. Reads come from memory; writes are
/// persisted in the background.
abstract class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// In-memory implementation (tests, fallback).
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : _data = {...?initial};
  final Map<String, String> _data;

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

/// Persists everything in one JSON file inside the app's private storage.
/// Uses only dart:io, so no native plugin is involved.
class FileKeyValueStore implements KeyValueStore {
  FileKeyValueStore._(this._file, this._data);

  static const androidPackage = 'ir.roboram.robolink';

  final File _file;
  final Map<String, String> _data;
  Future<void> _queue = Future.value();

  static Directory _storageDir() {
    if (Platform.isAndroid) {
      for (final base in [
        '/data/user/0/$androidPackage',
        '/data/data/$androidPackage',
      ]) {
        if (Directory(base).existsSync()) return Directory('$base/files');
      }
    }
    return Directory('${Directory.systemTemp.path}/robolink');
  }

  static Future<FileKeyValueStore> open() async {
    final file = File('${_storageDir().path}/robolink_store.json');
    var data = <String, String>{};
    try {
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) {
          data = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      }
    } catch (_) {
      // Unreadable file: start empty rather than failing at startup.
    }
    return FileKeyValueStore._(file, data);
  }

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> setString(String key, String value) {
    _data[key] = value;
    return _persist();
  }

  @override
  Future<void> remove(String key) {
    _data.remove(key);
    return _persist();
  }

  Future<void> _persist() {
    _queue = _queue.then((_) async {
      try {
        await _file.parent.create(recursive: true);
        final tmp = File('${_file.path}.tmp');
        await tmp.writeAsString(jsonEncode(_data), flush: true);
        await tmp.rename(_file.path);
      } catch (_) {
        // Best effort: the app keeps working from memory.
      }
    });
    return _queue;
  }
}
