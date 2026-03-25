import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'cache_provider.g.dart';

/// Simple cache provider to track initialization state
@riverpod
class Cache extends _$Cache {
  @override
  Map<String, bool> build() {
    return {};
  }

  /// Set a cache key to true
  void set(String key) {
    state = {...state, key: true};
  }

  /// Check if a cache key is set
  bool isSet(String key) {
    return state[key] == true;
  }

  /// Get all cache entries
  Map<String, bool> get all => state;
}
