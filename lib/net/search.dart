import 'package:dio/dio.dart';
import 'package:html_parser_plus/html_parser_plus.dart';

import '../common/constant.dart';
import '../types/search_result.dart';

Future<String?> fetchSearchPageUrl() async {
  final dio = Dio();
  var response = await dio.get(baseUrl);
  // print(response.data);
  final parser = HtmlParser();
  final document = parser.parse(response.data);
  // xpath 获取所有a标签
  final aTags = parser.queryNodes(document, '//span[@class="https"]/../..');
  for (var aTag in aTags) {
    return aTag.xpathNode?.parent?.attributes['href'];
  }

  return null;
}

Future<List<SearchResult>> fetchSearchResult(
    String url, String keyword, int page) async {
  final dio = Dio();
  String searchUrl;
  if (page == 1) {
    searchUrl = '$url/search/${Uri.encodeComponent(keyword)}';
  } else {
    searchUrl = '$url/search/${Uri.encodeComponent(keyword)}/page/$page';
  }
  var response = await dio.get(searchUrl);

  // var box = await Hive.openBox<HttpCache>('httpCache');
  // var cache = box.get('default');
  final content = response.data;

  final parser = HtmlParser();
  final document = parser.parse(content);
  // xpath 获取所有a标签
  final aTags = parser.queryNodes(document, '//div[@class="row"]');
  final results = <SearchResult>[];
  for (var aTag in aTags) {
    final children = aTag.xpathNode?.children;
    if (children == null || children.isEmpty) {
      continue;
    }

    var a = children[0];
    if (a.name.toString() != '<a>') {
      continue;
    }

    final title = a.attributes['title'];
    if (title == null) {
      continue;
    }

    final url = a.attributes['href'];
    if (url == null) {
      continue;
    }

    if (children.length < 3) {
      continue;
    }

    final size = children[1].text ?? '';
    final date = children[2].text ?? '';

    results.add(SearchResult(title: title, url: url, size: size, date: date));
  }

  return results;
}

Future<String?> copyMagToClipboard(String url) async {
  final targetUrl = 'https:$url';
  final dio = Dio();
  var response = await dio.get(targetUrl);
  final content = response.data;

  // final box = await Hive.openBox<HttpCache>('httpCache');
  // box.put('targetContent', HttpCache(content: content));
  // print('copyMagToClipboard: $targetUrl');

  // final box = await Hive.openBox<HttpCache>('httpCache');
  // final cache = box.get('targetContent');
  // if (cache == null) {
  //   return null;
  // }

  // print(cache.content);

  final parser = HtmlParser();
  final document = parser.parse(content);
  final aTags = parser.queryNodes(document, '//textarea[@id="magnetLink"]');
  for (var aTag in aTags) {
    return aTag.xpathNode?.text;
  }

  return null;
}
