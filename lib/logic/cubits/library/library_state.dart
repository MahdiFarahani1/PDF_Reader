import 'package:equatable/equatable.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/category_model.dart';

enum LibraryStatus { initial, loading, loaded, error }

class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<DocumentModel> documents;
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.documents = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.errorMessage,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<DocumentModel>? documents,
    List<CategoryModel>? categories,
    Object? selectedCategoryId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return LibraryState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId == _sentinel
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    status,
    documents,
    categories,
    selectedCategoryId,
    errorMessage,
  ];
}
