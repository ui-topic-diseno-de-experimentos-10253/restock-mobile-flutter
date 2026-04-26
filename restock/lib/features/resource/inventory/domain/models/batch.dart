 

import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';

class Batch {
  final String id;
  final int? userId;
  final int? userRoleId;
  final CustomSupply? customSupply;
  final int? customSupplyId;
  final double stock;
  final String? expirationDate;

  const Batch({
    required this.id,
    this.userId,
    this.userRoleId,
    this.customSupply,
    this.customSupplyId,
    required this.stock,
    this.expirationDate,
  });

  Batch copyWith({
    String? id,
    int? userId,
    int? userRoleId,
    CustomSupply? customSupply,
    double? stock,
    String? expirationDate,
    int? customSupplyId,
  }) {
    return Batch(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userRoleId: userRoleId ?? this.userRoleId,
      customSupply: customSupply ?? this.customSupply,
      stock: stock ?? this.stock,
      expirationDate: expirationDate ?? this.expirationDate,
      customSupplyId: customSupplyId ?? this.customSupplyId,
    );
  }
}
