 

import 'package:restock/features/resource/inventory/domain/models/supply.dart';
import 'package:restock/features/resource/inventory/domain/models/unit_model.dart';

class CustomSupply {
  final int id;
  final int minStock;
  final int maxStock;
  final double price;
  final int? userId;
  final int supplyId;
  final Supply? supply;
  final UnitModel unit;
  final String? currencyCode;
  final String description;

  const CustomSupply({
    required this.id,
    required this.minStock,
    required this.maxStock,
    required this.price,
    this.userId,
    required this.supplyId,
    this.supply,
    required this.unit,
    this.currencyCode,
    required this.description,
  });

  CustomSupply copyWith({
    int? id,
    int? minStock,
    int? maxStock,
    double? price,
    int? userId,
    int? supplyId,
    Supply? supply,
    UnitModel? unit,
    String? currencyCode,
    String? description,
  }) {
    return CustomSupply(
      id: id ?? this.id,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      price: price ?? this.price,
      userId: userId ?? this.userId,
      supplyId: supplyId ?? this.supplyId,
      supply: supply ?? this.supply,
      unit: unit ?? this.unit,
      currencyCode: currencyCode ?? this.currencyCode,
      description: description ?? this.description,
    );
  }
}
