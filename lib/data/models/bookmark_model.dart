import 'package:equatable/equatable.dart';

class BookmarkModel extends Equatable {
  final String id;
  final String documentId;
  final int? pageNumber; // For PDF/EPUB
  final int? textPosition; // For TXT (character position)
  final String? cfi; // For EPUB (Canonical Fragment Identifier)
  final String? label; // Optional user label
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.documentId,
    this.pageNumber,
    this.textPosition,
    this.cfi,
    this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'pageNumber': pageNumber,
      'textPosition': textPosition,
      'cfi': cfi,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] ?? '',
      documentId: map['documentId'] ?? '',
      pageNumber: map['pageNumber'],
      textPosition: map['textPosition'],
      cfi: map['cfi'],
      label: map['label'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  BookmarkModel copyWith({
    String? id,
    String? documentId,
    int? pageNumber,
    int? textPosition,
    String? cfi,
    String? label,
    DateTime? createdAt,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageNumber: pageNumber ?? this.pageNumber,
      textPosition: textPosition ?? this.textPosition,
      cfi: cfi ?? this.cfi,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    documentId,
    pageNumber,
    textPosition,
    label,
    createdAt,
  ];
}
