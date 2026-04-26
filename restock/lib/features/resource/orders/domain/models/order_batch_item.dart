 

import 'package:restock/features/resource/inventory/domain/models/batch.dart';

class OrderBatchItem {
  final int batchId;
  final double quantity;
  final bool accepted;
  final Batch? batch;

  const OrderBatchItem({
    required this.batchId,
    required this.quantity,
    required this.accepted,
    this.batch,
  });

  OrderBatchItem copyWith({
    int? batchId,
    double? quantity,
    bool? accepted,
    Batch? batch,
  }) {
    return OrderBatchItem(
      batchId: batchId ?? this.batchId,
      quantity: quantity ?? this.quantity,
      accepted: accepted ?? this.accepted,
      batch: batch ?? this.batch,
    );
  }
}
