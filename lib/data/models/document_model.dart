enum FileType { pdf, epub, txt, word, sheet, unknown }

class DocumentModel {
  final String id;
  final String path;
  final String title;
  final FileType fileType;
  final double size; // in MB
  final DateTime dateAdded;
  final String? coverPath;
  final int? currentPage; // For PDF/EPUB
  final int? lastReadPosition; // For TXT (character position)
  final DateTime? lastOpenedAt;
  final String? categoryId;

  const DocumentModel({
    required this.id,
    required this.path,
    required this.title,
    required this.fileType,
    required this.size,
    required this.dateAdded,
    this.coverPath,
    this.currentPage,
    this.lastReadPosition,
    this.lastOpenedAt,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'fileType': fileType.index,
      'size': size,
      'dateAdded': dateAdded.toIso8601String(),
      'coverPath': coverPath,
      'currentPage': currentPage,
      'lastReadPosition': lastReadPosition,
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      path: map['path'] ?? '',
      title: map['title'] ?? 'Untitled',
      fileType: FileType.values[map['fileType'] ?? FileType.unknown.index],
      size: map['size']?.toDouble() ?? 0.0,
      dateAdded: DateTime.parse(map['dateAdded']),
      coverPath: map['coverPath'],
      currentPage: map['currentPage'],
      lastReadPosition: map['lastReadPosition'],
      lastOpenedAt: map['lastOpenedAt'] != null
          ? DateTime.parse(map['lastOpenedAt'])
          : null,
      categoryId: map['categoryId'],
    );
  }

  DocumentModel copyWith({
    String? id,
    String? path,
    String? title,
    FileType? fileType,
    double? size,
    DateTime? dateAdded,
    Object? coverPath = _sentinel,
    Object? currentPage = _sentinel,
    Object? lastReadPosition = _sentinel,
    Object? lastOpenedAt = _sentinel,
    Object? categoryId = _sentinel,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      fileType: fileType ?? this.fileType,
      size: size ?? this.size,
      dateAdded: dateAdded ?? this.dateAdded,
      coverPath: coverPath == _sentinel ? this.coverPath : coverPath as String?,
      currentPage: currentPage == _sentinel
          ? this.currentPage
          : currentPage as int?,
      lastReadPosition: lastReadPosition == _sentinel
          ? this.lastReadPosition
          : lastReadPosition as int?,
      lastOpenedAt: lastOpenedAt == _sentinel
          ? this.lastOpenedAt
          : lastOpenedAt as DateTime?,
      categoryId: categoryId == _sentinel
          ? this.categoryId
          : categoryId as String?,
    );
  }

  static const _sentinel = Object();
}
