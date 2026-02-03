import 'package:flutter/material.dart';
import '../../data/models/search_result_model.dart';

class SearchOverlay extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClose;
  final Function(SearchResultModel) onResultTap;
  final List<SearchResultModel> results;
  final int? currentIndex;
  final String? searchQuery;
  final bool isSearching;

  const SearchOverlay({
    super.key,
    required this.onSearch,
    required this.onClose,
    required this.onResultTap,
    required this.results,
    this.currentIndex,
    this.searchQuery,
    this.isSearching = false,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    if (widget.results.isNotEmpty) {
      _isExpanded = true;
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SearchOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.results.isNotEmpty && !_isExpanded) {
      setState(() => _isExpanded = true);
      _animationController.forward();
    } else if (widget.results.isEmpty &&
        _isExpanded &&
        _controller.text.isEmpty) {
      setState(() => _isExpanded = false);
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.search, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search in document...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    onSubmitted: widget.onSearch,
                    autofocus: true,
                  ),
                ),
                if (widget.results.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.results.length} matches',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
          if (widget.isSearching) const LinearProgressIndicator(minHeight: 2),

          // Results List (Animated)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                children: [
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.results.length,
                      separatorBuilder: (context, index) =>
                          const Divider(indent: 16, endIndent: 16, height: 1),
                      itemBuilder: (context, index) {
                        final result = widget.results[index];
                        final isSelected = widget.currentIndex == index;

                        return ListTile(
                          onTap: () => widget.onResultTap(result),
                          selected: isSelected,
                          selectedColor: colorScheme.primary,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          title: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: _buildHighlightedSnippet(
                              context,
                              result.snippet,
                              widget.searchQuery ?? '',
                            ),
                          ),
                          trailing: result.pageNumber != null
                              ? Text(
                                  'Page ${result.pageNumber}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                )
                              : const Icon(Icons.chevron_right, size: 16),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildHighlightedSnippet(
    BuildContext context,
    String snippet,
    String query,
  ) {
    if (query.isEmpty) return TextSpan(text: snippet);

    final lowerSnippet = snippet.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerSnippet.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: snippet.substring(start, indexOfMatch)));
      }

      spans.add(
        TextSpan(
          text: snippet.substring(indexOfMatch, indexOfMatch + query.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
      );

      start = indexOfMatch + query.length;
    }

    if (start < snippet.length) {
      spans.add(TextSpan(text: snippet.substring(start)));
    }

    return TextSpan(
      children: spans,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
