import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/category_model.dart';
import '../../../core/services/storage_service.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final StorageService _storageService;
  static const String _storageKey = 'library_documents';
  static const String _categoryStorageKey = 'library_categories';

  LibraryCubit(this._storageService) : super(const LibraryState()) {
    _loadData();
  }

  void _loadData() {
    emit(state.copyWith(status: LibraryStatus.loading));
    try {
      final List<dynamic>? storedDocs = _storageService.read<List<dynamic>>(
        _storageKey,
      );
      final List<dynamic>? storedCategories = _storageService
          .read<List<dynamic>>(_categoryStorageKey);

      final documents = storedDocs != null
          ? storedDocs.map((e) => DocumentModel.fromMap(e)).toList()
          : <DocumentModel>[];

      final categories = storedCategories != null
          ? storedCategories.map((e) => CategoryModel.fromMap(e)).toList()
          : <CategoryModel>[];

      emit(
        state.copyWith(
          status: LibraryStatus.loaded,
          documents: documents,
          categories: categories,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: LibraryStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _saveData() async {
    final docsMap = state.documents.map((e) => e.toMap()).toList();
    final categoriesMap = state.categories.map((e) => e.toMap()).toList();
    await _storageService.write(_storageKey, docsMap);
    await _storageService.write(_categoryStorageKey, categoriesMap);
  }

  // --- Document Operations ---

  Future<void> addDocument(
    String path,
    String title,
    FileType type,
    double size, {
    String? categoryId,
  }) async {
    final newDoc = DocumentModel(
      id: const Uuid().v4(),
      path: path,
      title: title,
      fileType: type,
      size: size,
      dateAdded: DateTime.now(),
      categoryId: categoryId,
    );

    final updatedList = List<DocumentModel>.from(state.documents)..add(newDoc);
    emit(state.copyWith(documents: updatedList));
    await _saveData();
  }

  Future<void> removeDocument(String id) async {
    final updatedList = state.documents.where((doc) => doc.id != id).toList();
    emit(state.copyWith(documents: updatedList));
    await _saveData();
  }

  Future<void> updateDocument(DocumentModel document) async {
    final updatedList = state.documents.map((doc) {
      return doc.id == document.id ? document : doc;
    }).toList();
    emit(state.copyWith(documents: updatedList));
    await _saveData();
  }

  Future<void> assignDocumentToCategory(
    String documentId,
    String? categoryId,
  ) async {
    final updatedList = state.documents.map((doc) {
      if (doc.id == documentId) {
        return doc.copyWith(categoryId: categoryId);
      }
      return doc;
    }).toList();
    emit(state.copyWith(documents: updatedList));
    await _saveData();
  }

  // --- Category Operations ---

  Future<void> createCategory(String name, {String? iconPath}) async {
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      iconPath: iconPath,
      dateCreated: DateTime.now(),
    );

    final updatedList = List<CategoryModel>.from(state.categories)
      ..add(newCategory);
    emit(state.copyWith(categories: updatedList));
    await _saveData();
  }

  Future<void> deleteCategory(String id) async {
    // Also remove reference from documents
    final updatedDocs = state.documents.map((doc) {
      if (doc.categoryId == id) {
        return doc.copyWith(categoryId: null);
      }
      return doc;
    }).toList();

    final updatedCategories = state.categories
        .where((cat) => cat.id != id)
        .toList();

    emit(state.copyWith(categories: updatedCategories, documents: updatedDocs));
    await _saveData();
  }

  Future<void> renameCategory(String id, String newName) async {
    final updatedList = state.categories.map((cat) {
      if (cat.id == id) {
        return cat.copyWith(name: newName);
      }
      return cat;
    }).toList();
    emit(state.copyWith(categories: updatedList));
    await _saveData();
  }

  void setCategoryFilter(String? categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }
}
