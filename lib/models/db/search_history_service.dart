import 'package:hive/hive.dart';
import 'search_history.dart';

class SearchHistoryService {
  static const String _boxName = 'search_history';
  static const int _maxHistoryCount = 50;

  late Box<SearchHistory> _box;

  // Initialize the service
  Future<void> init() async {
    _box = await Hive.openBox<SearchHistory>(_boxName);
  }

  // Add a new search query to history
  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;

    // Remove existing entry with same query
    await removeSearchQuery(query);

    // Add new entry
    final history = SearchHistory(
      query: query.trim(),
      timestamp: DateTime.now(),
    );
    await _box.add(history);

    // Limit history count
    await _limitHistoryCount();
  }

  // Get all search history, sorted by timestamp (newest first)
  List<SearchHistory> getAllHistory() {
    final history = _box.values.toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  // Remove a specific search query from history
  Future<void> removeSearchQuery(String query) async {
    final keysToDelete = <dynamic>[];
    for (int i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final history = _box.get(key);
      if (history?.query == query.trim()) {
        keysToDelete.add(key);
      }
    }
    await _box.deleteAll(keysToDelete);
  }

  // Clear all search history
  Future<void> clearAllHistory() async {
    await _box.clear();
  }

  // Limit the number of history entries
  Future<void> _limitHistoryCount() async {
    if (_box.length <= _maxHistoryCount) return;

    final history = getAllHistory();
    final toDelete = history.sublist(_maxHistoryCount);

    for (final item in toDelete) {
      await item.delete();
    }
  }

  // Close the box
  Future<void> close() async {
    await _box.close();
  }
}
