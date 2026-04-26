// lib/features/resource/inventory/presentation/blocs/inventory_event.dart
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';

abstract class InventoryEvent {
  const InventoryEvent();
}

class InventoryClearRequested extends InventoryEvent {
  const InventoryClearRequested();
}

class InventoryLoadRequested extends InventoryEvent {
  const InventoryLoadRequested();
}

// BATCHES
class CreateBatchEvent extends InventoryEvent {
  final Batch batch;
  const CreateBatchEvent(this.batch);
}

class UpdateBatchEvent extends InventoryEvent {
  final Batch batch;
  const UpdateBatchEvent(this.batch);
}

class DeleteBatchEvent extends InventoryEvent {
  final String id;
  const DeleteBatchEvent(this.id);
}

// CUSTOM SUPPLIES
class CreateCustomSupplyEvent extends InventoryEvent {
  final CustomSupply supply;
  const CreateCustomSupplyEvent(this.supply);
}

class UpdateCustomSupplyEvent extends InventoryEvent {
  final CustomSupply supply;
  const UpdateCustomSupplyEvent(this.supply);
}

class DeleteCustomSupplyEvent extends InventoryEvent {
  final int id;
  const DeleteCustomSupplyEvent(this.id);
}
