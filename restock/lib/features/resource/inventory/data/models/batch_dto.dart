 
import 'package:restock/features/resource/inventory/data/models/custom_supply_dto.dart';
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/unit_model.dart';

class BatchDto {
  final String? id;
  final int? userId;
  final int? userRoleId;
  final int? customSupplyId;
  final double? stock;
  final String? expirationDate;
  final CustomSupplyDto? customSupply;

  const BatchDto({
    this.id,
    this.userId,
    this.userRoleId,
    this.customSupplyId,
    this.stock,
    this.expirationDate,
    this.customSupply,
  });

  factory BatchDto.fromJson(Map<String, dynamic> json) {
  return BatchDto(
    id: json['id']?.toString(),        // A veces viene como int
    userId: json['userId'],
    userRoleId: json['userRoleId'],
    customSupplyId: json['customSupplyId'],
    stock: (json['stock'] as num?)?.toDouble(),
    expirationDate: json['expirationDate'],
    customSupply: json['customSupply'] != null
        ? CustomSupplyDto.fromJson(json['customSupply'])
        : null,
  );
}


  Batch toDomain({List<CustomSupply>? customSupplies}) {
    return Batch(
      id: id ?? '',
      userId: userId,
      userRoleId: userRoleId,
      customSupply: customSupply != null
          ? customSupply!.toDomain()
          : customSupplyId != null
              ? customSupplies?.firstWhere(
                    (c) => c.id == customSupplyId,
                    orElse: () => CustomSupply(
                      id: customSupplyId!,
                      description: '',
                      minStock: 0,
                      maxStock: 0,
                      price: 0.0,
                      userId: null,
                      supplyId: 0,
                      supply: null,
                      unit: UnitModel(name: '', abbreviation: ''),
                      currencyCode: '',
                    ),
                  )
              : null,
      stock: stock ?? 0.0,
      expirationDate: expirationDate,
    );
  }

  factory BatchDto.fromDomain(Batch batch) {
    return BatchDto(
      id: batch.id,
      userId: batch.userId,
      userRoleId: batch.userRoleId,
      customSupplyId: batch.customSupply?.id,
      stock: batch.stock,
      expirationDate: batch.expirationDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userRoleId': userRoleId,
        'customSupplyId': customSupplyId,
        'stock': stock,
        'expirationDate': expirationDate,
      };
}