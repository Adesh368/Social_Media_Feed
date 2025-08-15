import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/cache_helper.dart';

class UsersAsyncNotifier extends AsyncNotifier<List<User>> {
  // Key for storing cached users JSON in SharedPreferences
  static const _cacheKey = 'cached_users';

  // Cached users loaded from cache or API
  List<User>? _cachedUsers;

  // Timestamp of last fetch to manage cache freshness
  DateTime? _lastFetch;

  // Called when provider initializes, builds initial state
  @override
  Future<List<User>> build() async {
    // Attempt to load cached user list from SharedPreferences
    final cachedJson = await CacheHelper.getData(_cacheKey);

    if (cachedJson != null) {
      try {
        // Decode cached JSON into List<User>
        final cachedList =
            (cachedJson as List).map((e) => User.fromJson(e)).toList();

        _cachedUsers = cachedList;
        _lastFetch = DateTime.now(); // Mark cache fresh
        state = AsyncValue.data(cachedList); // Set state with cached users
        return cachedList; // Return cached list immediately
      } catch (_) {
        // Parsing error: proceed to fetch fresh data
      }
    }

    // No cache or parse fail: fetch fresh users from API
    return await _fetchAndCacheUsers();
  }

  // Fetch users from API and cache result
  Future<List<User>> _fetchAndCacheUsers() async {
  final asyncValue = await AsyncValue.guard(() async {
    final users = await ApiService.fetchUsers();
    _cachedUsers = users;
    _lastFetch = DateTime.now();
    final usersJsonList = users.map((e) => e.toJson()).toList();
    await CacheHelper.saveData(_cacheKey, usersJsonList);
    return users;
  });

  // Check if AsyncValue contains data or error and react accordingly
  return asyncValue.when(
    data: (users) => users,
    loading: () => throw Exception('Loading should not happen here'),
    error: (err, stack) => throw err, // propagate error upwards
  );
}

}

// Expose AsyncNotifierProvider for users
final usersProvider =
    AsyncNotifierProvider<UsersAsyncNotifier, List<User>>(() {
  return UsersAsyncNotifier();
});
