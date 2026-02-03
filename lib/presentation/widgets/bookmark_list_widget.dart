import 'package:flutter/material.dart';
import '../../data/models/bookmark_model.dart';
import 'package:intl/intl.dart';

class BookmarkListWidget extends StatelessWidget {
  final List<BookmarkModel> bookmarks;
  final Function(BookmarkModel) onBookmarkTap;
  final Function(String) onBookmarkDelete;

  const BookmarkListWidget({
    super.key,
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onBookmarkDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (bookmarks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No bookmarks yet.\nTap the bookmark icon to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return ListTile(
          leading: const Icon(Icons.bookmark, color: Colors.blue),
          title: Text(
            bookmark.label ??
                (bookmark.pageNumber != null
                    ? 'Page ${bookmark.pageNumber}'
                    : 'Position ${bookmark.textPosition}'),
          ),
          subtitle: Text(
            DateFormat.yMMMd().add_jm().format(bookmark.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onBookmarkDelete(bookmark.id),
          ),
          onTap: () => onBookmarkTap(bookmark),
        );
      },
    );
  }
}
