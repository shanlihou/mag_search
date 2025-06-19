import 'package:flutter/material.dart';
import '../net/search.dart';
import '../types/search_result.dart';

Future<String?> showSearchResultDialog(
    BuildContext context, SearchResult searchResult) async {
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(searchResult.title),
      content: Column(
        children: [
          Text(searchResult.title),
          Text(searchResult.url),
          Text(searchResult.size),
          Text(searchResult.date),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, searchResult.url);
          },
          child: Text('Download'),
        ),
      ],
    ),
  );
}
