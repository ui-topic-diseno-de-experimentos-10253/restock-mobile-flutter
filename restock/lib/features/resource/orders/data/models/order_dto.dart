// lib/features/resources/orders/data/models/order_dto.dart

import 'package:restock/features/auth/data/models/user_dto.dart';
import 'package:restock/features/auth/domain/models/user.dart';
import 'package:restock/features/resource/orders/data/models/order_batch_item_dto.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart'; 

class OrderDto {
  final int? id;
  final int? adminRestaurantId;
  final int? supplierId;
  final UserDto? supplier;
  final String? requestedDate;
  final bool? partiallyAccepted;
  final int? requestedProductsCount;
  final double? totalPrice;
  final String? state;
  final String? situation;
  final List<OrderBatchItemDto>? batchItems;

  final String? description;     
  final String? estimatedShipDate;
  final String? estimatedShipTime;

  const OrderDto({
    this.id,
    this.adminRestaurantId,
    this.supplierId,
    this.supplier,
    this.requestedDate,
    this.partiallyAccepted,
    this.requestedProductsCount,
    this.totalPrice,
    this.state,
    this.situation,
    this.batchItems,
    this.description,
    this.estimatedShipDate,
    this.estimatedShipTime,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    print('OrderDto.fromJson recibido: $json'); // DEBUG
    
    final List items = json['batchItems'] ?? [];

    return OrderDto(
      id: json['id'],
      adminRestaurantId: json['adminRestaurantId'],
      supplierId: json['supplierId'],
      supplier: json['supplier'] != null 
          ? UserDto.fromJson(json['supplier']) 
          : null,
      requestedDate: json['date']?.toString(),
      partiallyAccepted: json['partiallyAccepted'] ?? false,
      requestedProductsCount: json['requestedProductsCount'],
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      state: json['state']?.toString(),
      situation: json['situation']?.toString(),
      batchItems: items
          .map((e) => OrderBatchItemDto.fromJson(e))
          .toList()
          .cast<OrderBatchItemDto>(),
      description: json['description']?.toString(),
      estimatedShipDate: json['estimatedShipDate']?.toString(),
      estimatedShipTime: json['estimatedShipTime']?.toString()
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'adminRestaurantId': adminRestaurantId,
        'supplierId': supplierId,
        'supplier': supplier?.toJson(),
        'date': requestedDate,
        'partiallyAccepted': partiallyAccepted,
        'requestedProductsCount': requestedProductsCount,
        'totalPrice': totalPrice,
        'state': state,
        'situation': situation,
        'batchItems': batchItems?.map((e) => e.toJson()).toList(),
        'description': description,
        'estimatedShipDate': estimatedShipDate,
        'estimatedShipTime': estimatedShipTime,
      };

  Order toDomain() {
    final User supplierUser = supplier?.toDomain() ??
        User(
          id: supplierId ?? 0,
          username: 'Supplier_${supplierId ?? 0}',
          roleId: 1,
          token: '',
          profile: null,
          subscription: 0,
        );

    final parsedDate = requestedDate != null
        ? (requestedDate!.split('T').isNotEmpty
            ? requestedDate!.split('T').first
            : requestedDate!)
        : '';

    

    return Order(
      id: id ?? 0,
      adminRestaurantId: adminRestaurantId ?? 0,
      supplierId: supplierId ?? 0,
      supplier: supplierUser,
      requestedDate: parsedDate,
      partiallyAccepted: partiallyAccepted ?? false,
      requestedProductsCount: requestedProductsCount ?? 0,
      totalPrice: totalPrice ?? 0.0,
      state: _parseState(state),
      situation: _parseSituation(situation),
      batchItems:
          batchItems?.map((item) => item.toDomain()).toList() ?? const [],
      description: description ?? '',
      estimatedShipDate: estimatedShipDate ?? '',
      estimatedShipTime: estimatedShipTime ?? '',
    );
  }

  OrderState _parseState(String? value) {
    switch (value) {
      case 'PREPARING':
        return OrderState.preparing;
      case 'ON_THE_WAY':
        return OrderState.onTheWay;
      case 'DELIVERED':
        return OrderState.delivered;
      case 'ON_HOLD':
      default:
        return OrderState.onHold;
    }
  }

  OrderSituation _parseSituation(String? value) {
    switch (value) {
      case 'APPROVED':
        return OrderSituation.approved;
      case 'DECLINED':
        return OrderSituation.declined;
      case 'CANCELLED':
        return OrderSituation.cancelled;
      case 'PENDING':
      default:
        return OrderSituation.pending;
    }
  }
}