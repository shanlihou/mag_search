import 'package:flutter/material.dart';

class SearchFilter extends StatefulWidget {
  final Function(String? minSize, String? maxSize, String? titleKeyword)
      onFilterChanged;
  final bool isActive;

  const SearchFilter({
    super.key,
    required this.onFilterChanged,
    this.isActive = false,
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  final TextEditingController _minSizeController = TextEditingController();
  final TextEditingController _maxSizeController = TextEditingController();
  final TextEditingController _titleKeywordController = TextEditingController();
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  @override
  void dispose() {
    _minSizeController.dispose();
    _maxSizeController.dispose();
    _titleKeywordController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    final minSize = _minSizeController.text.trim().isEmpty
        ? null
        : _minSizeController.text.trim();
    final maxSize = _maxSizeController.text.trim().isEmpty
        ? null
        : _maxSizeController.text.trim();
    final titleKeyword = _titleKeywordController.text.trim().isEmpty
        ? null
        : _titleKeywordController.text.trim();

    final isActive = minSize != null || maxSize != null || titleKeyword != null;

    setState(() {
      _isActive = isActive;
    });

    widget.onFilterChanged(minSize, maxSize, titleKeyword);
  }

  void _clearFilters() {
    _minSizeController.clear();
    _maxSizeController.clear();
    _titleKeywordController.clear();
    _onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (_isActive)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Size filter section
          const Text(
            'Size Filter',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Min Size',
                    hintText: 'e.g., 1MB, 500KB',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => _onFilterChanged(),
                ),
              ),
              const SizedBox(width: 8),
              const Text('to'),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Max Size',
                    hintText: 'e.g., 1GB, 100MB',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => _onFilterChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Size format: KB, MB, GB (case insensitive)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          // Title filter section
          const Text(
            'Title Filter',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleKeywordController,
            decoration: const InputDecoration(
              labelText: 'Title Keyword',
              hintText: 'Enter keyword to match in title',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) => _onFilterChanged(),
          ),
          const SizedBox(height: 8),
          Text(
            'Title filter performs exact word matching',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
