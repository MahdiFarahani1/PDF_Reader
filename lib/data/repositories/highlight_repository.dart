import '../models/highlight_model.dart';
import '../../core/services/storage_service.dart';

class HighlightRepository {
  final StorageService _storageService;
  static const String _storageKey = 'highlights';

  HighlightRepository(this._storageService);

  // Get all highlights for a specific document
  Future<List<HighlightModel>> getHighlightsForDocument(
    String documentId,
  ) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return [];

    final allHighlights = storedList
        .map((e) => HighlightModel.fromMap(e))
        .toList();
    return allHighlights.where((h) => h.documentId == documentId).toList();
  }

  // Add a highlight
  Future<void> addHighlight(HighlightModel highlight) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    final highlights =
        storedList?.map((e) => HighlightModel.fromMap(e)).toList() ?? [];

    highlights.add(highlight);
    await _saveHighlights(highlights);
  }

  // Remove a highlight
  Future<void> removeHighlight(String highlightId) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return;

    final highlights = storedList
        .map((e) => HighlightModel.fromMap(e))
        .toList();
    highlights.removeWhere((h) => h.id == highlightId);
    await _saveHighlights(highlights);
  }

  // Update highlight (mainly for editing notes)
  Future<void> updateHighlight(HighlightModel highlight) async {
    final List<dynamic>? storedList = _storageService.read<List<dynamic>>(
      _storageKey,
    );
    if (storedList == null) return;

    final highlights = storedList
        .map((e) => HighlightModel.fromMap(e))
        .toList();
    final index = highlights.indexWhere((h) => h.id == highlight.id);
    if (index != -1) {
      highlights[index] = highlight.copyWith(updatedAt: DateTime.now());
      await _saveHighlights(highlights);
    }
  }

  Future<void> _saveHighlights(List<HighlightModel> highlights) async {
    final highlightsMap = highlights.map((e) => e.toMap()).toList();
    await _storageService.write(_storageKey, highlightsMap);
  }
}
