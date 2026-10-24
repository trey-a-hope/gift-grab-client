import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clerk_auth/clerk_auth.dart';
import 'package:clerk_flutter/src/utils/clerk_file_cache.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Clerk's default persistor writes to `getApplicationDocumentsDirectory`,
/// which path_provider doesn't support on web. This stores values in Hive
/// (IndexedDB on web) instead.
class ClerkWebPersistor implements Persistor {
  static const _boxName = 'clerk_sdk';

  Box<String>? _box;

  @override
  Future<void> initialize() async {
    _box ??= await Hive.openBox<String>(_boxName);
  }

  @override
  void terminate() {}

  // Values are JSON-encoded so nested maps come back as Map<String, dynamic>,
  // which is what Clerk expects when restoring the client/environment.
  @override
  FutureOr<T?> read<T>(String key) {
    final raw = _box?.get(key);
    return raw == null ? null : jsonDecode(raw) as T?;
  }

  @override
  FutureOr<void> write<T>(String key, T value) =>
      _box?.put(key, jsonEncode(value));

  @override
  FutureOr<void> delete(String key) => _box?.delete(key);
}

/// Clerk's file cache relies on `dart:io` files, which don't exist on web.
/// Emitting nothing makes Clerk's cached images render as empty placeholders.
class ClerkWebFileCache extends ClerkFileCache {
  @override
  Stream<File> stream(
    Uri uri, {
    Duration ttl = ClerkFileCache.defaultTTL,
    Map<String, String>? headers,
  }) => const Stream.empty();
}
