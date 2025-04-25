import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/utils_widget.dart';
import '../../net/search.dart';
import '../../types/search_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = []; // 这里可以根据实际数据模型修改类型
  String? _searchPageUrl;

  void _performSearch(String query) async {
    setState(() {
      _searchResults.clear();
    });

    _searchPageUrl ??= await fetchSearchPageUrl();

    if (_searchPageUrl == null) {
      return;
    }

    _searchResults = await fetchSearchResult(_searchPageUrl!, query);

    setState(() {});
  }

  void _onTapSearchResult(SearchResult searchResult) async {
    final mag = await showSearchResultDialog(context, searchResult);
    if (mag != null) {
      Clipboard.setData(ClipboardData(text: mag));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Magnet link copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Please enter a search keyword',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _performSearch(_searchController.text);
                      },
                    ),
                  ],
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: _searchResults[index].toWidget(),
                  onTap: () {
                    _onTapSearchResult(_searchResults[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
