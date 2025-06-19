import 'package:hive/hive.dart';

part 'download_history.g.dart';

@HiveType(typeId: 2)
class DownloadHistory extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime timestamp;

  DownloadHistory({
    required this.url,
    required this.title,
    required this.timestamp,
  });
}
