import 'package:hive/hive.dart';

part 'http_cache.g.dart';

@HiveType(typeId: 0)
class HttpCache {
  @HiveField(0)
  String content;

  HttpCache({required this.content});

  factory HttpCache.fromJson(Map<String, dynamic> json) {
    return HttpCache(content: json['content']);
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
