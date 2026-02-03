import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:epubx/epubx.dart' as epub;
import '../../../data/models/bookmark_model.dart';
import '../../../data/models/highlight_model.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/search_result_model.dart';
import '../../../data/repositories/bookmark_repository.dart';
import '../../../data/repositories/highlight_repository.dart';
import '../library/library_cubit.dart';
import 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final BookmarkRepository _bookmarkRepository;
  final HighlightRepository _highlightRepository;
  final LibraryCubit _libraryCubit;

  ReaderCubit(
    this._bookmarkRepository,
    this._highlightRepository,
    this._libraryCubit,
  ) : super(const ReaderState());

  // Initialize reader for a document
  Future<void> initializeDocument(
    String documentId, {
    int? savedPage,
    int? savedPosition,
  }) async {
    emit(state.copyWith(status: ReaderStatus.loading));

    try {
      // Load bookmarks and highlights
      final bookmarks = await _bookmarkRepository.getBookmarksForDocument(
        documentId,
      );
      final highlights = await _highlightRepository.getHighlightsForDocument(
        documentId,
      );

      emit(
        state.copyWith(
          status: ReaderStatus.loaded,
          documentId: documentId,
          currentPage: savedPage,
          currentPosition: savedPosition,
          bookmarks: bookmarks,
          highlights: highlights,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ReaderStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // Update current page/position and auto-save
  Future<void> updatePosition({int? page, int? position}) async {
    emit(state.copyWith(currentPage: page, currentPosition: position));

    // Auto-save to document
    if (state.documentId != null) {
      await _autoSavePosition();
    }
  }

  Future<void> _autoSavePosition() async {
    // Find the document in library and update its position
    final doc = _libraryCubit.state.documents.firstWhere(
      (d) => d.id == state.documentId,
      orElse: () => throw Exception('Document not found'),
    );

    final updatedDoc = doc.copyWith(
      currentPage: state.currentPage,
      lastReadPosition: state.currentPosition,
      lastOpenedAt: DateTime.now(),
    );

    await _libraryCubit.updateDocument(updatedDoc);
  }

  // Add bookmark
  Future<void> addBookmark({
    int? pageNumber,
    int? textPosition,
    String? cfi,
    String? label,
  }) async {
    if (state.documentId == null) return;

    final bookmark = BookmarkModel(
      id: const Uuid().v4(),
      documentId: state.documentId!,
      pageNumber: pageNumber,
      textPosition: textPosition,
      cfi: cfi,
      label: label,
      createdAt: DateTime.now(),
    );

    await _bookmarkRepository.addBookmark(bookmark);

    // Reload bookmarks
    final bookmarks = await _bookmarkRepository.getBookmarksForDocument(
      state.documentId!,
    );
    emit(state.copyWith(bookmarks: bookmarks));
  }

  // Remove bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    await _bookmarkRepository.removeBookmark(bookmarkId);

    if (state.documentId != null) {
      final bookmarks = await _bookmarkRepository.getBookmarksForDocument(
        state.documentId!,
      );
      emit(state.copyWith(bookmarks: bookmarks));
    }
  }

  // Add highlight
  Future<void> addHighlight({
    required String selectedText,
    int? pageNumber,
    int? startPosition,
    int? endPosition,
    required Color color,
    String? note,
  }) async {
    if (state.documentId == null) return;

    final highlight = HighlightModel(
      id: const Uuid().v4(),
      documentId: state.documentId!,
      selectedText: selectedText,
      pageNumber: pageNumber,
      startPosition: startPosition,
      endPosition: endPosition,
      color: color,
      note: note,
      createdAt: DateTime.now(),
    );

    await _highlightRepository.addHighlight(highlight);

    // Reload highlights
    final highlights = await _highlightRepository.getHighlightsForDocument(
      state.documentId!,
    );
    emit(state.copyWith(highlights: highlights));
  }

  // Update highlight note
  Future<void> updateHighlightNote(String highlightId, String note) async {
    final highlight = state.highlights.firstWhere((h) => h.id == highlightId);
    final updated = highlight.copyWith(note: note, updatedAt: DateTime.now());

    await _highlightRepository.updateHighlight(updated);

    if (state.documentId != null) {
      final highlights = await _highlightRepository.getHighlightsForDocument(
        state.documentId!,
      );
      emit(state.copyWith(highlights: highlights));
    }
  }

  // Remove highlight
  Future<void> removeHighlight(String highlightId) async {
    await _highlightRepository.removeHighlight(highlightId);

    if (state.documentId != null) {
      final highlights = await _highlightRepository.getHighlightsForDocument(
        state.documentId!,
      );
      emit(state.copyWith(highlights: highlights));
    }
  }

  // Search functionality
  String _normalizeText(String text, {bool keepLength = false}) {
    if (text.isEmpty) return "";
    var result = text
        .replaceAll('\u0643', '\u06a9') // Arabic Kaf
        .replaceAll('\u064a', '\u06cc') // Arabic Yeh
        .replaceAll('\u0649', '\u06cc') // Alef Maksura
        .replaceAll('\u0626', '\u06cc') // Hamza on Yeh
        .replaceAll('\u0640', '') // Always remove Tatweel
        .replaceAll('\u200c', '') // Always remove ZWNJ
        .replaceAll('\u200d', ''); // Always remove ZWJ

    if (keepLength) {
      // Replace diacritics with space to keep indices aligned
      // Note: Length might change slightly if Tatweels/ZWNJ were removed.
      // But they are rare enough that a small shift is better than a no-match.
      result = result.replaceAll(RegExp(r'[\u064b-\u0652]'), ' ');
    } else {
      result = result.replaceAll(RegExp(r'[\u064b-\u0652]'), '');
    }

    return result.toLowerCase().trim();
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          searchResults: [],
          currentSearchIndex: null,
          searchQuery: null,
          isSearching: false,
        ),
      );
      return;
    }

    if (state.documentId == null) return;

    emit(
      state.copyWith(searchQuery: query, isSearching: true, searchResults: []),
    );

    // Find the document to get path and type
    final doc = _libraryCubit.state.documents.firstWhere(
      (d) => d.id == state.documentId,
      orElse: () => throw Exception('Document not found'),
    );

    List<SearchResultModel> results = [];
    final normalizedQuery = _normalizeText(query);

    if (doc.fileType == FileType.txt) {
      try {
        final content = await io.File(doc.path).readAsString();
        final searchReadyText = _normalizeText(content, keepLength: true);

        int index = 0;
        int matchCount = 0;

        while ((index = searchReadyText.indexOf(normalizedQuery, index)) !=
            -1) {
          final start = (index - 40).clamp(0, content.length);
          final end = (index + query.length + 40).clamp(0, content.length);
          var snippet = content.substring(start, end).replaceAll('\n', ' ');

          results.add(
            SearchResultModel(
              id: 'match_${matchCount++}',
              snippet:
                  '${start > 0 ? '...' : ''}$snippet${end < content.length ? '...' : ''}',
              startPosition: index,
              endPosition: index + query.length,
            ),
          );
          index += query.length;
          if (matchCount >= 100) break;
        }
      } catch (e) {
        debugPrint('Search error: $e');
      }
    } else if (doc.fileType == FileType.pdf) {
    } else if (doc.fileType == FileType.epub) {
      try {
        final bytes = await io.File(doc.path).readAsBytes();
        final epubBook = await epub.EpubReader.readBook(bytes);
        int matchCount = 0;
        int chapterIndex = 1;

        for (var chapter in epubBook.Chapters ?? []) {
          final content = chapter.HtmlContent ?? '';
          // Remove HTML tags for searching
          final plainText = content.replaceAll(RegExp(r'<[^>]*>'), ' ');
          final searchReadyText = _normalizeText(plainText, keepLength: true);

          int index = 0;
          while ((index = searchReadyText.indexOf(normalizedQuery, index)) !=
              -1) {
            final start = (index - 40).clamp(0, plainText.length);
            final end = (index + query.length + 40).clamp(0, plainText.length);
            var snippet = plainText.substring(start, end).replaceAll('\n', ' ');

            results.add(
              SearchResultModel(
                id: 'epub_match_${matchCount++}',
                snippet:
                    'Ch. $chapterIndex: ${start > 0 ? '...' : ''}$snippet${end < plainText.length ? '...' : ''}',
                pageNumber:
                    chapterIndex, // Using chapter index as page number for EPUB
                startPosition: index,
                endPosition: index + query.length,
              ),
            );
            index += query.length;
            if (matchCount >= 100) break;
          }
          chapterIndex++;
          if (matchCount >= 100) break;
        }
      } catch (e) {
        debugPrint('EPUB Search error: $e');
      }
    }

    emit(
      state.copyWith(
        searchResults: results,
        currentSearchIndex: results.isNotEmpty ? 0 : null,
        isSearching: false,
      ),
    );
  }

  void _addPdfSearchResult(
    List<SearchResultModel> results,
    int matchId,
    int pageIndex,
    String fullText,
    String query,
    int index,
  ) {
    final start = (index - 40).clamp(0, fullText.length);
    final end = (index + query.length + 40).clamp(0, fullText.length);
    var snippet = fullText.substring(start, end).replaceAll('\n', ' ');

    results.add(
      SearchResultModel(
        id: 'pdf_match_$matchId',
        snippet:
            'Page ${pageIndex + 1}: ${start > 0 ? '...' : ''}$snippet${end < fullText.length ? '...' : ''}',
        pageNumber: pageIndex + 1,
        startPosition: index,
        endPosition: index + query.length,
      ),
    );
  }

  void clearSearch() {
    emit(state.copyWith(searchResults: [], currentSearchIndex: null));
  }

  void nextSearchResult() {
    if (state.searchResults.isEmpty) return;

    final currentIndex = state.currentSearchIndex ?? -1;
    final nextIndex = (currentIndex + 1) % state.searchResults.length;
    emit(state.copyWith(currentSearchIndex: nextIndex));
  }

  void previousSearchResult() {
    if (state.searchResults.isEmpty) return;

    final currentIndex = state.currentSearchIndex ?? 0;
    final prevIndex =
        (currentIndex - 1 + state.searchResults.length) %
        state.searchResults.length;
    emit(state.copyWith(currentSearchIndex: prevIndex));
  }
}
