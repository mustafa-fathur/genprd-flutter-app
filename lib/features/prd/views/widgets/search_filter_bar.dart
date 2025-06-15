import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filters,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search PRDs...',
                prefixIcon: const Icon(CupertinoIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              onChanged: onSearchChanged,
              controller: TextEditingController(text: searchQuery),
            ),
          ),
          const SizedBox(width: 8),
          // Filter dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: const Icon(CupertinoIcons.line_horizontal_3_decrease),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onChanged: onFilterChanged,
                items:
                    filters.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
