import 'package:flutter/material.dart';

class SizeFilter extends StatefulWidget {
  final Function(double? minSize, double? maxSize) onFilterChanged;
  final bool isActive;

  const SizeFilter({
    super.key,
    required this.onFilterChanged,
    this.isActive = false,
  });

  @override
  State<SizeFilter> createState() => _SizeFilterState();
}

class _SizeFilterState extends State<SizeFilter> {
  final TextEditingController _minSizeController = TextEditingController();
  final TextEditingController _maxSizeController = TextEditingController();
  String _selectedUnit = 'MB';
  bool _isActive = false;

  final List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  @override
  void dispose() {
    _minSizeController.dispose();
    _maxSizeController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    double? minSize;
    double? maxSize;

    if (_minSizeController.text.isNotEmpty) {
      minSize = _parseSize(_minSizeController.text);
    }
    if (_maxSizeController.text.isNotEmpty) {
      maxSize = _parseSize(_maxSizeController.text);
    }

    widget.onFilterChanged(minSize, maxSize);
  }

  void _clearFilter() {
    _minSizeController.clear();
    _maxSizeController.clear();
    setState(() {
      _isActive = false;
    });
    widget.onFilterChanged(null, null);
  }

  double? _parseSize(String sizeText) {
    if (sizeText.isEmpty) return null;

    try {
      final size = double.parse(sizeText);
      // Convert to bytes based on selected unit
      switch (_selectedUnit) {
        case 'B':
          return size;
        case 'KB':
          return size * 1024;
        case 'MB':
          return size * 1024 * 1024;
        case 'GB':
          return size * 1024 * 1024 * 1024;
        case 'TB':
          return size * 1024 * 1024 * 1024 * 1024;
        default:
          return size;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Size Filter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (_isActive)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: _clearFilter,
                  tooltip: 'Clear filter',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Min Size',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Text('to', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Max Size',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedUnit,
                items: _units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedUnit = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isActive = true;
                    });
                    _applyFilter();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Apply Filter',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
