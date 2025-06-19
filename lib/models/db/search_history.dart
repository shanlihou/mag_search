import 'package:hive/hive.dart';

part 'search_history.g.dart';

@HiveType(typeId: 1)
class SearchHistory extends HiveObject {
  @HiveField(0)
  String query;

  @HiveField(1)
  DateTime timestamp;

  SearchHistory({
    required this.query,
    required this.timestamp,
  });
}
