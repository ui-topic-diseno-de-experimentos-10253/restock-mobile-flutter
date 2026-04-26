 
import 'package:restock/features/resource/inventory/domain/models/supply.dart';

class SupplyDto {
  final int? id;
  final String? name;
  final String? description;
  final bool? perishable;
  final String? category;

  const SupplyDto({
    this.id,
    this.name,
    this.description,
    this.perishable,
    this.category,
  });

  factory SupplyDto.fromJson(Map<String, dynamic> json) {
    return SupplyDto(
      id: json['id'] as int?,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      perishable: json['perishable'] as bool?,
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'perishable': perishable,
        'category': category,
      };

  Supply toDomain() {
    return Supply(
      id: id ?? 0,
      name: name ?? '',
      description: description ?? '',
      perishable: perishable ?? false,
      category: category ?? '',
    );
  }

  factory SupplyDto.fromDomain(Supply supply) {
    return SupplyDto(
      id: supply.id,
      name: supply.name,
      description: supply.description,
      perishable: supply.perishable,
      category: supply.category,
    );
  }
}