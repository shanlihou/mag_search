import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../common/log.dart';
import '../../common/utils_widget.dart';
import '../../common/size_parser.dart';
import '../../net/search.dart';
import '../../types/search_result.dart';
import '../../models/db/search_history.dart';
import '../../models/db/search_history_service.dart';
import '../../models/db/download_history.dart';
import '../../models/db/download_history_service.dart';
import '../widgets/search_filter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final DownloadHistoryService _downloadHistoryService =
      DownloadHistoryService();
  List<SearchResult> _searchResults = [];
  List<SearchResult> _filteredResults = [];
  List<SearchHistory> _searchHistory = [];
  Map<String, bool> _downloadStatus = {};
  String? _searchPageUrl;
  bool _isLoading = false;
  bool _showHistory = false;
  bool _showFilter = false;
  bool _isFilterActive = false;
  String? _minSize;
  String? _maxSize;
  String? _titleKeyword;
  int _currentPage = 1;
  final _easyRefreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _easyRefreshController.dispose();
    _searchHistoryService.close();
    _downloadHistoryService.close();
    super.dispose();
  }

  Future<void> _initServices() async {
    await _searchHistoryService.init();
    await _downloadHistoryService.init();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    setState(() {
      _searchHistory = _searchHistoryService.getAllHistory();
    });
  }

  Future<void> _loadDownloadStatus() async {
    final statusMap = <String, bool>{};
    for (final result in _searchResults) {
      statusMap[result.url] =
          await _downloadHistoryService.hasDownloaded(result.url);
    }
    setState(() {
      _downloadStatus = statusMap;
    });
  }

  void _performSearch(String query, {bool isLoadMore = false}) async {
    if (_isLoading) return;

    if (!isLoadMore) {
      _currentPage = 1;
      setState(() {
        _searchResults.clear();
        _filteredResults.clear();
        _downloadStatus.clear();
        _showHistory = false;
      });

      // Save search query to history
      if (query.trim().isNotEmpty) {
        await _searchHistoryService.addSearchQuery(query);
        _loadSearchHistory();
      }
    }

    setState(() {
      _isLoading = true;
    });

    if (!isLoadMore) {
      if (mounted) {
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
    }

    try {
      _searchPageUrl ??= await fetchSearchPageUrl();

      if (_searchPageUrl == null) {
        return;
      }

      final newResults =
          await fetchSearchResult(_searchPageUrl!, query, _currentPage);

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _searchResults.addAll(newResults);
            _currentPage++;
          } else {
            _searchResults = newResults;
            _currentPage = 2;
          }
        });

        // Load download status for new results
        await _loadDownloadStatus();

        // Apply filter to new results
        _applyFilter();
      }

      _easyRefreshController.finishLoad(
        newResults.isEmpty ? IndicatorResult.noMore : IndicatorResult.success,
      );
    } catch (e) {
      Log.instance.e('perform search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (!isLoadMore) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _onFilterChanged(
      String? minSize, String? maxSize, String? titleKeyword) {
    setState(() {
      _minSize = minSize;
      _maxSize = maxSize;
      _titleKeyword = titleKeyword;
      _isFilterActive =
          minSize != null || maxSize != null || titleKeyword != null;
    });
    _applyFilter();
  }

  void _applyFilter() {
    if (!_isFilterActive) {
      setState(() {
        _filteredResults = List.from(_searchResults);
      });
      return;
    }

    setState(() {
      _filteredResults = _searchResults.where((result) {
        // Size filter
        if (_minSize != null || _maxSize != null) {
          final sizeInBytes = SizeParser.parseSize(result.size);
          if (sizeInBytes == null) return false;

          if (_minSize != null) {
            final minSizeInBytes = SizeParser.parseSize(_minSize!);
            if (minSizeInBytes == null || sizeInBytes < minSizeInBytes) {
              return false;
            }
          }

          if (_maxSize != null) {
            final maxSizeInBytes = SizeParser.parseSize(_maxSize!);
            if (maxSizeInBytes == null || sizeInBytes > maxSizeInBytes) {
              return false;
            }
          }
        }

        // Title filter
        if (_titleKeyword != null && _titleKeyword!.isNotEmpty) {
          final title = result.title.toLowerCase();
          final keyword = _titleKeyword!.toLowerCase();

          // Check if any word in the title matches the keyword
          final titleWords = title.split(RegExp(r'\s+'));
          final keywordWords = keyword.split(RegExp(r'\s+'));

          bool hasMatch = false;
          for (final titleWord in titleWords) {
            for (final keywordWord in keywordWords) {
              if (titleWord.contains(keywordWord) ||
                  keywordWord.contains(titleWord)) {
                hasMatch = true;
                break;
              }
            }
            if (hasMatch) break;
          }

          if (!hasMatch) return false;
        }

        return true;
      }).toList();
    });
  }

  void _onTapSearchResult(SearchResult searchResult) async {
    final url = await showSearchResultDialog(context, searchResult);
    if (url == null) {
      return;
    }

    final mag = await copyMagToClipboard(url);
    Log.instance.i('mag: $mag');
    if (mag != null) {
      try {
        Clipboard.setData(ClipboardData(text: mag));

        // Record download history
        await _downloadHistoryService.addDownloadRecord(
            url, searchResult.title);

        // Update download status
        setState(() {
          _downloadStatus[searchResult.url] = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Magnet link copied to clipboard')),
          );
        }
      } catch (e) {
        Log.instance.e('copy magnet link to clipboard error: $e');
      }
    }
  }

  void _onHistoryItemTap(SearchHistory history) {
    setState(() {
      _searchController.text = history.query;
      _showHistory = false;
    });
  }

  void _onHistoryItemDelete(SearchHistory history) async {
    await _searchHistoryService.removeSearchQuery(history.query);
    _loadSearchHistory();
  }

  void _clearAllHistory() async {
    await _searchHistoryService.clearAllHistory();
    _loadSearchHistory();
  }

  Widget _buildSearchHistoryList() {
    if (_searchHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No search history',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final history = _searchHistory[index];
        return ListTile(
          leading: const Icon(Icons.history, color: Colors.grey),
          title: Text(history.query),
          subtitle: Text(
            _formatTimestamp(history.timestamp),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () => _onHistoryItemDelete(history),
          ),
          onTap: () => _onHistoryItemTap(history),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TalkerScreen(talker: Log.instance.logger),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
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
                              _filteredResults.clear();
                              _downloadStatus.clear();
                              _showHistory = false;
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
                  onTap: () {
                    if (_searchHistory.isNotEmpty) {
                      setState(() {
                        _showHistory = true;
                        _showFilter = false;
                      });
                    }
                  },
                ),
                if (_showHistory && _searchHistory.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Search History',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: _clearAllHistory,
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Flexible(child: _buildSearchHistoryList()),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFilter = !_showFilter;
                            _showHistory = false;
                          });
                        },
                        icon: Icon(_showFilter
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label:
                            Text(_showFilter ? 'Hide Filter' : 'Show Filter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFilterActive ? Colors.blue[100] : null,
                        ),
                      ),
                    ),
                    if (_isFilterActive)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_filteredResults.length}/${_searchResults.length}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (_showFilter)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SearchFilter(
                      onFilterChanged: _onFilterChanged,
                      isActive: _isFilterActive,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showHistory = false;
                  _showFilter = false;
                });
              },
              child: EasyRefresh(
                controller: _easyRefreshController,
                onLoad: () async {
                  if (_searchController.text.isNotEmpty) {
                    Log.instance.i('onLoad');
                    _performSearch(_searchController.text, isLoadMore: true);
                  }
                },
                child: ListView.builder(
                  itemCount: _filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = _filteredResults[index];
                    final isDownloaded = _downloadStatus[result.url] ?? false;

                    return GestureDetector(
                      onTap: () {
                        _onTapSearchResult(result);
                      },
                      child: result.toWidget(isDownloaded: isDownloaded),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
