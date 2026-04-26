import 'package:restock/features/profiles/domain/models/business_category.dart';

class CategoryDto {
  final String id;
  final String name;

  const CategoryDto({required this.id, required this.name});

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  BusinessCategory toDomain() => BusinessCategory(id: id, name: name);
}
