import 'package:hive/hive.dart';
import 'download_history.dart';

class DownloadHistoryService {
  static const String _boxName = 'download_history';

  late Box<DownloadHistory> _box;

  // Initialize the service
  Future<void> init() async {
    _box = await Hive.openBox<DownloadHistory>(_boxName);
  }

  // Add a new download record
  Future<void> addDownloadRecord(String url, String title) async {
    if (url.trim().isEmpty) return;

    // Check if already exists
    if (await hasDownloaded(url)) return;

    final history = DownloadHistory(
      url: url.trim(),
      title: title.trim(),
      timestamp: DateTime.now(),
    );
    await _box.add(history);
  }

  // Check if a URL has been downloaded before
  Future<bool> hasDownloaded(String url) async {
    for (int i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final history = _box.get(key);
      if (history?.url == url.trim()) {
        return true;
      }
    }
    return false;
  }

  // Get download timestamp for a URL
  Future<DateTime?> getDownloadTime(String url) async {
    for (int i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final history = _box.get(key);
      if (history?.url == url.trim()) {
        return history?.timestamp;
      }
    }
    return null;
  }

  // Get all download history, sorted by timestamp (newest first)
  List<DownloadHistory> getAllHistory() {
    final history = _box.values.toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history;
  }

  // Remove a specific download record
  Future<void> removeDownloadRecord(String url) async {
    final keysToDelete = <dynamic>[];
    for (int i = 0; i < _box.length; i++) {
      final key = _box.keyAt(i);
      final history = _box.get(key);
      if (history?.url == url.trim()) {
        keysToDelete.add(key);
      }
    }
    await _box.deleteAll(keysToDelete);
  }

  // Clear all download history
  Future<void> clearAllHistory() async {
    await _box.clear();
  }

  // Close the box
  Future<void> close() async {
    await _box.close();
  }
}
