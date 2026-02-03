import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class HighlightModel extends Equatable {
  final String id;
  final String documentId;
  final String selectedText;
  final int? pageNumber; // For PDF/EPUB
  final int? startPosition; // For TXT or precise positioning
  final int? endPosition;
  final Color color;
  final String? note; // Optional note attached to highlight
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HighlightModel({
    required this.id,
    required this.documentId,
    required this.selectedText,
    this.pageNumber,
    this.startPosition,
    this.endPosition,
    required this.color,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'selectedText': selectedText,
      'pageNumber': pageNumber,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'color': color.value,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HighlightModel.fromMap(Map<String, dynamic> map) {
    return HighlightModel(
      id: map['id'] ?? '',
      documentId: map['documentId'] ?? '',
      selectedText: map['selectedText'] ?? '',
      pageNumber: map['pageNumber'],
      startPosition: map['startPosition'],
      endPosition: map['endPosition'],
      color: Color(map['color'] ?? Colors.yellow.value),
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  HighlightModel copyWith({
    String? id,
    String? documentId,
    String? selectedText,
    int? pageNumber,
    int? startPosition,
    int? endPosition,
    Color? color,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HighlightModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      selectedText: selectedText ?? this.selectedText,
      pageNumber: pageNumber ?? this.pageNumber,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      color: color ?? this.color,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    documentId,
    selectedText,
    pageNumber,
    startPosition,
    endPosition,
    color,
    note,
    createdAt,
    updatedAt,
  ];
}
