
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';

class CustomSupplyRequestDto {
  final int? id;
  final int supplyId;
  final String description;
  final int minStock;
  final int maxStock;
  final double price;
  final int userId;
  final String unitName;
  final String unitAbbreviaton;

  const CustomSupplyRequestDto({
    this.id,
    required this.supplyId,
    required this.description,
    required this.minStock,
    required this.maxStock,
    required this.price,
    required this.userId,
    required this.unitName,
    required this.unitAbbreviaton,
  });

  /// Crea el request a partir del modelo de dominio + userId (como en Kotlin)
  factory CustomSupplyRequestDto.fromDomain(
    CustomSupply custom,
    int userId,
  ) {
    return CustomSupplyRequestDto(
      id: custom.id == 0 ? null : custom.id,
      supplyId: custom.supplyId,
      description: custom.description,
      minStock: custom.minStock,
      maxStock: custom.maxStock,
      price: custom.price,
      userId: custom.userId ?? userId,
      unitName: custom.unit.name,
      unitAbbreviaton: custom.unit.abbreviation,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'supplyId': supplyId,
        'description': description,
        'minStock': minStock,
        'maxStock': maxStock,
        'price': price,
        'userId': userId,
        'unitName': unitName,
        'unitAbbreviaton': unitAbbreviaton,
      };
}
