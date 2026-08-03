import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:quran_one/core/database/app_database.dart';

/// Cache entries live in SQLite, not in memory.
///
/// A memory cache is empty on every cold start, which is precisely the
/// moment a user on a bad connection most needs it.
class CacheEntry {
  const CacheEntry({required this.body, required this.storedAt});

  final String body;
  final DateTime storedAt;

  bool isExpired(Duration ttl) =>
      DateTime.now().difference(storedAt) > ttl;

  Response<dynamic> toResponse(RequestOptions options) => Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: jsonDecode(body),
        extra: {'fromCache': true},
      );
}

abstract interface class ResponseCache {
  Future<CacheEntry?> read(String key);
  Future<void> write(String key, Object? body);
  Future<void> evict(String prefix);
  Future<void> clear();
}

class SqliteResponseCache implements ResponseCache {
  const SqliteResponseCache(this._db);

  final AppDatabase _db;

  @override
  Future<CacheEntry?> read(String key) async {
    final row = await _db.readCache(key);
    if (row == null) return null;
    return CacheEntry(body: row.body, storedAt: row.storedAt);
  }

  @override
  Future<void> write(String key, Object? body) =>
      _db.writeCache(key: key, body: jsonEncode(body), storedAt: DateTime.now());

  @override
  Future<void> evict(String prefix) => _db.evictCache(prefix);

  @override
  Future<void> clear() => _db.clearCache();
}
