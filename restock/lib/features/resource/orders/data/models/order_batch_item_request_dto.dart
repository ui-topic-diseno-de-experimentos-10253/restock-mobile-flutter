// lib/features/resources/orders/data/models/order_batch_item_request_dto.dart
 
import 'package:restock/features/resource/orders/domain/models/order_batch_item.dart';

class OrderBatchItemRequestDto {
  final int batchId;
  final double quantity;
  final bool accept;

  const OrderBatchItemRequestDto({
    required this.batchId,
    required this.quantity,
    this.accept = false,
  });

  factory OrderBatchItemRequestDto.fromDomain(OrderBatchItem item) {
    return OrderBatchItemRequestDto(
      batchId: item.batchId,
      quantity: item.quantity,
      accept: item.accepted,
    );
  }

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'quantity': quantity,
        'accept': accept,
      };
}
