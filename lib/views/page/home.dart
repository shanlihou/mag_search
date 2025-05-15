import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_refresh/easy_refresh.dart';

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
  List<SearchResult> _searchResults = [];
  String? _searchPageUrl;
  bool _isLoading = false;
  int _currentPage = 1;
  final _easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  @override
  void dispose() {
    _easyRefreshController.dispose();
    super.dispose();
  }

  void _performSearch(String query, {bool isLoadMore = false}) async {
    if (_isLoading) return;

    if (!isLoadMore) {
      _currentPage = 1;
      setState(() {
        _searchResults.clear();
      });
    }

    setState(() {
      _isLoading = true;
    });

    if (!isLoadMore) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }

    try {
      _searchPageUrl ??= await fetchSearchPageUrl();

      if (_searchPageUrl == null) {
        return;
      }

      final newResults =
          await fetchSearchResult(_searchPageUrl!, query, _currentPage);

      setState(() {
        if (isLoadMore) {
          _searchResults.addAll(newResults);
          _currentPage++;
        } else {
          _searchResults = newResults;
          _currentPage = 2;
        }
      });

      _easyRefreshController.finishLoad(
        newResults.isEmpty ? IndicatorResult.noMore : IndicatorResult.success,
      );
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
      if (!isLoadMore) {
        Navigator.of(context).pop();
      }
    }
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
              onSubmitted: (query) => _performSearch(query),
            ),
          ),
          Expanded(
            child: EasyRefresh(
              controller: _easyRefreshController,
              onLoad: () async {
                if (_searchController.text.isNotEmpty) {
                  print('onLoad');
                  _performSearch(_searchController.text, isLoadMore: true);
                }
              },
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
          ),
        ],
      ),
    );
  }
}
