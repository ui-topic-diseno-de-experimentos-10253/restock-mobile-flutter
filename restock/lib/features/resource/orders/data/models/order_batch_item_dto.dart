 
import 'package:restock/features/resource/inventory/data/models/batch_dto.dart';
import 'package:restock/features/resource/orders/domain/models/order_batch_item.dart';

class OrderBatchItemDto {
  final int? batchId;
  final double? quantity;
  final bool? accepted;
  final BatchDto? batch;

  const OrderBatchItemDto({
    this.batchId,
    this.quantity,
    this.accepted,
    this.batch,
  });

  factory OrderBatchItemDto.fromJson(Map<String, dynamic> json) {
    return OrderBatchItemDto(
      batchId: json['batchId'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      accepted: json['accept'],
      batch: json['batch'] != null ? BatchDto.fromJson(json['batch']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'quantity': quantity,
        'accepted': accepted,
        'batch': batch?.toJson(),
      };

  OrderBatchItem toDomain() {
    return OrderBatchItem(
      batchId: batchId ?? 0,
      quantity: quantity ?? 0.0,
      accepted: accepted ?? false,
      batch: batch?.toDomain(),
    );
  }

  factory OrderBatchItemDto.fromDomain(OrderBatchItem item) {
    return OrderBatchItemDto(
      batchId: item.batchId,
      quantity: item.quantity,
      accepted: item.accepted,
      batch: item.batch != null ? BatchDto.fromDomain(item.batch!) : null,
    );
  }
}
