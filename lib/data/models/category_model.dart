import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? iconPath;
  final DateTime dateCreated;

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconPath,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconPath: map['iconPath'],
      dateCreated: DateTime.parse(map['dateCreated']),
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconPath,
    DateTime? dateCreated,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  @override
  List<Object?> get props => [id, name, iconPath, dateCreated];
}
