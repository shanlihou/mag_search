class SizeParser {
  // Parse size string to bytes
  // Supports formats like: 1KB, 1MB, 1GB, 1kb, 1mb, 1gb
  static int? parseSize(String sizeStr) {
    if (sizeStr.isEmpty) return null;

    // Remove any whitespace and convert to uppercase
    final cleanSize = sizeStr.trim().toUpperCase();

    // Extract number and unit
    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(KB|MB|GB|TB)$');
    final match = regex.firstMatch(cleanSize);

    if (match == null) return null;

    final number = double.parse(match.group(1)!);
    final unit = match.group(2)!;

    // Convert to bytes
    switch (unit) {
      case 'KB':
        return (number * 1024).round();
      case 'MB':
        return (number * 1024 * 1024).round();
      case 'GB':
        return (number * 1024 * 1024 * 1024).round();
      case 'TB':
        return (number * 1024 * 1024 * 1024 * 1024).round();
      default:
        return null;
    }
  }

  // Format bytes to human readable string
  static String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes < 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB';
    }
  }

  // Check if a size string is valid
  static bool isValidSize(String sizeStr) {
    return parseSize(sizeStr) != null;
  }
}
