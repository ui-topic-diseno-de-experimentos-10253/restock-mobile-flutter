
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/supply.dart';

abstract class InventoryRepository {
  // --- Supplies ---
  Future<List<Supply>> getSupplies();

  // Custom Supplies
  Future<List<CustomSupply>> getCustomSupplies();
  Future<List<CustomSupply>> getCustomSuppliesByUserId();
  Future<CustomSupply?> createCustomSupply(CustomSupply custom);
  Future<CustomSupply?> updateCustomSupply(CustomSupply custom);
  Future<void> deleteCustomSupply(int customSupplyId);

  // Batches
  Future<List<Batch>> getBatches();
  Future<List<Batch>> getBatchesByUserId();
  Future<Batch?> createBatch(Batch batch);
  Future<Batch?> updateBatch(Batch batch);
  Future<void> deleteBatch(String batchId);
  
  Future<List<Batch>> getBatchesByUser(int userId);
  Future<List<CustomSupply>> getCustomSuppliesByUser(int userId);
}
