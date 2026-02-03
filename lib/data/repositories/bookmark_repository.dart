import '../models/bookmark_model.dart';
import '../../core/services/storage_service.dart';

class BookmarkRepository {
  final StorageService _storageService;
  static const String _storageKey = 'bookmarks';

  BookmarkRepository(this._storageService);

  // Get all bookmarks for a specific document
  Future<List<BookmarkModel>> getBookmarksForDocument(String documentId) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return [];

    final allBookmarks = storedList
        .map((e) => BookmarkModel.fromMap(e))
        .toList();
    return allBookmarks.where((b) => b.documentId == documentId).toList();
  }

  // Add a bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    final bookmarks =
        storedList?.map((e) => BookmarkModel.fromMap(e)).toList() ?? [];

    bookmarks.add(bookmark);
    await _saveBookmarks(bookmarks);
  }

  // Remove a bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return;

    final bookmarks = storedList.map((e) => BookmarkModel.fromMap(e)).toList();
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    await _saveBookmarks(bookmarks);
  }

  // Update bookmark label
  Future<void> updateBookmark(BookmarkModel bookmark) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return;

    final bookmarks = storedList.map((e) => BookmarkModel.fromMap(e)).toList();
    final index = bookmarks.indexWhere((b) => b.id == bookmark.id);
    if (index != -1) {
      bookmarks[index] = bookmark;
      await _saveBookmarks(bookmarks);
    }
  }

  Future<void> _saveBookmarks(List<BookmarkModel> bookmarks) async {
    final bookmarksMap = bookmarks.map((e) => e.toMap()).toList();
    await _storageService.write(_storageKey, bookmarksMap);
  }
}
