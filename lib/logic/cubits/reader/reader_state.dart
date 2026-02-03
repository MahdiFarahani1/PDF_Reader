import 'package:equatable/equatable.dart';
import '../../../data/models/bookmark_model.dart';
import '../../../data/models/highlight_model.dart';
import '../../../data/models/search_result_model.dart';

enum ReaderStatus { initial, loading, loaded, error }

class ReaderState extends Equatable {
  final ReaderStatus status;
  final String? documentId;
  final int? currentPage;
  final int? currentPosition;
  final List<BookmarkModel> bookmarks;
  final List<HighlightModel> highlights;
  final List<SearchResultModel> searchResults;
  final int? currentSearchIndex;
  final String? errorMessage;
  final String? searchQuery;
  final bool isSearching;

  const ReaderState({
    this.status = ReaderStatus.initial,
    this.documentId,
    this.currentPage,
    this.currentPosition,
    this.bookmarks = const [],
    this.highlights = const [],
    this.searchResults = const [],
    this.currentSearchIndex,
    this.errorMessage,
    this.searchQuery,
    this.isSearching = false,
  });

  ReaderState copyWith({
    ReaderStatus? status,
    String? documentId,
    int? currentPage,
    int? currentPosition,
    List<BookmarkModel>? bookmarks,
    List<HighlightModel>? highlights,
    List<SearchResultModel>? searchResults,
    int? currentSearchIndex,
    String? errorMessage,
    String? searchQuery,
    bool? isSearching,
  }) {
    return ReaderState(
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      currentPage: currentPage ?? this.currentPage,
      currentPosition: currentPosition ?? this.currentPosition,
      bookmarks: bookmarks ?? this.bookmarks,
      highlights: highlights ?? this.highlights,
      searchResults: searchResults ?? this.searchResults,
      currentSearchIndex: currentSearchIndex ?? this.currentSearchIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    status,
    documentId,
    currentPage,
    currentPosition,
    bookmarks,
    highlights,
    searchResults,
    currentSearchIndex,
    errorMessage,
    searchQuery,
    isSearching,
  ];
}
