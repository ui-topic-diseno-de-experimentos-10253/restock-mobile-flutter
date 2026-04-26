 
import 'package:restock/features/resource/inventory/data/models/supply_dto.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/unit_model.dart';

class CustomSupplyDto {
  final int? id;
  final SupplyDto? supply;
  final String? description;
  final int? minStock;
  final int? maxStock;
  final double? price;
  final int? userId;
  final String? unitName;
  final String? unitAbbreviaton;
  final String? currencyCode;

  const CustomSupplyDto({
    this.id,
    this.supply,
    this.description,
    this.minStock,
    this.maxStock,
    this.price,
    this.userId,
    this.unitName,
    this.unitAbbreviaton,
    this.currencyCode,
  });

  factory CustomSupplyDto.fromJson(Map<String, dynamic> json) {
    return CustomSupplyDto(
      id: json['id'],
      supply:
          json['supply'] != null ? SupplyDto.fromJson(json['supply']) : null,
      description: json['description'],
      minStock: json['minStock'],
      maxStock: json['maxStock'],
      price: (json['price'] as num?)?.toDouble(),
      userId: json['userId'],
      unitName: json['unitName'],
      unitAbbreviaton: json['unitAbbreviaton'],
      currencyCode: json['currencyCode'],
    );
  }

  CustomSupply toDomain() {
    return CustomSupply(
      id: id ?? 0,
      description: description ?? '',
      minStock: minStock ?? 0,
      maxStock: maxStock ?? 0,
      price: price ?? 0.0,
      userId: userId,
      supplyId: supply?.id ?? 0,
      supply: supply?.toDomain(),
      unit: UnitModel(
        name: unitName ?? '',
        abbreviation: unitAbbreviaton ?? '',
      ),
      currencyCode: currencyCode ?? '',
    );
  }
}