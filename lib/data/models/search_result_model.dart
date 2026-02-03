import 'package:equatable/equatable.dart';

class SearchResultModel extends Equatable {
  final String id;
  final String snippet;
  final int? pageNumber; // For PDF/EPUB
  final int? startPosition; // For TXT/EPUB
  final int? endPosition;

  const SearchResultModel({
    required this.id,
    required this.snippet,
    this.pageNumber,
    this.startPosition,
    this.endPosition,
  });

  @override
  List<Object?> get props => [
    id,
    snippet,
    pageNumber,
    startPosition,
    endPosition,
  ];
}
