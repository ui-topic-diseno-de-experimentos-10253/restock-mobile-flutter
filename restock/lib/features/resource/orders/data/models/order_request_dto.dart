// lib/features/resource/orders/data/models/order_request_dto.dart

import 'package:restock/features/resource/orders/data/models/order_batch_item_request_dto.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_situation.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';

class OrderRequestDto {
  final int adminRestaurantId;
  final int supplierId;
  final String requestedDate; // campo "date" en el backend
  final bool partiallyAccepted;
  final int requestedProductsCount;
  final double totalPrice;
  final String state;
  final String situation;
  final List<OrderBatchItemRequestDto> batches;

  const OrderRequestDto({
    required this.adminRestaurantId,
    required this.supplierId,
    required this.requestedDate,
    this.partiallyAccepted = false,
    required this.requestedProductsCount,
    required this.totalPrice,
    required this.state,
    required this.situation,
    required this.batches,
  });

  /// helpers para enums -> string API usando las extensiones apiValue
  static String _stateToApi(OrderState state) => state.apiValue;
  static String _situationToApi(OrderSituation situation) =>
      situation.apiValue;

  /// Construye el request desde el modelo de dominio
  factory OrderRequestDto.fromDomain(Order order) {
    return OrderRequestDto(
      adminRestaurantId: order.adminRestaurantId,
      supplierId: order.supplierId,
      requestedDate: order.requestedDate,
      partiallyAccepted: order.partiallyAccepted,
      requestedProductsCount: order.requestedProductsCount,
      totalPrice: order.totalPrice,
      state: _stateToApi(order.state),
      situation: _situationToApi(order.situation),
      batches: order.batchItems
          .map((item) => OrderBatchItemRequestDto.fromDomain(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'adminRestaurantId': adminRestaurantId,
        'supplierId': supplierId,
        'date': requestedDate,
        'partiallyAccepted': partiallyAccepted,
        'requestedProductsCount': requestedProductsCount,
        'totalPrice': totalPrice,
        'state': state,
        'situation': situation,
        'batches': batches.map((b) => b.toJson()).toList(),
      };
}
