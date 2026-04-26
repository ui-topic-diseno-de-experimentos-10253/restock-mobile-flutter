import 'package:restock/features/resource/inventory/data/models/batch_dto.dart';
import 'package:restock/features/resource/inventory/data/models/custom_supply_request_dto.dart';
import 'package:restock/features/resource/inventory/data/remote/inventory_service.dart';
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/supply.dart';
import 'package:restock/features/resource/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryService service;

  /// Equivalente a TokenManager.getUserId() de Kotlin
  final Future<int?> Function() getUserId;

  InventoryRepositoryImpl({required this.service, required this.getUserId});

  // ---------------------------------------------------------
  // SUPPLIES
  // ---------------------------------------------------------
  @override
  Future<List<Supply>> getSupplies() async {
    try {
      final dtos = await service.getSupplies();
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------
  // CUSTOM SUPPLIES
  // ---------------------------------------------------------
  @override
  Future<List<CustomSupply>> getCustomSupplies() async {
    try {
      final dtos = await service.getCustomSupplies();
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CustomSupply>> getCustomSuppliesByUserId() async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];
      final dtos = await service.getCustomSuppliesByUserId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CustomSupply?> createCustomSupply(CustomSupply custom) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final request = CustomSupplyRequestDto.fromDomain(custom, userId);
      final resp = await service.createCustomSupply(request);
      return resp?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomSupply?> updateCustomSupply(CustomSupply custom) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final request = CustomSupplyRequestDto.fromDomain(custom, userId);
      final resp = await service.updateCustomSupply(custom.id, request);
      return resp?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteCustomSupply(int customSupplyId) async {
    try {
      await service.deleteCustomSupply(customSupplyId);
    } catch (_) {
      // ignore
    }
  }

  // ---------------------------------------------------------
  // BATCHES
  // ---------------------------------------------------------
  @override
  Future<List<Batch>> getBatches() async {
    try {
      final dtos = await service.getBatches();
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Batch>> getBatchesByUserId() async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];
      final dtos = await service.getBatchesByUserId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Batch?> createBatch(Batch batch) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final dto = BatchDto(
        id: batch.id,
        userId: userId,
        userRoleId: batch.userRoleId,
        customSupplyId: batch.customSupply?.id,
        stock: batch.stock,
        expirationDate: batch.expirationDate,
      );

      final resp = await service.createBatch(dto);
      return resp?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Batch?> updateBatch(Batch batch) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final dto = BatchDto(
        id: batch.id,
        userId: userId,
        userRoleId: batch.userRoleId,
        customSupplyId: batch.customSupply?.id,
        stock: batch.stock,
        expirationDate: batch.expirationDate,
      );

      final resp = await service.updateBatch(batch.id, dto);
      return resp?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    try {
      await service.deleteBatch(batchId);
    } catch (_) {
      // ignore
    }
  }
 
  @override
  Future<List<Batch>> getBatchesByUser(int userId) async {
    try {
      final dtos = await service.getBatchesByUserId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CustomSupply>> getCustomSuppliesByUser(int userId) async {
    try {
      final dtos = await service.getCustomSuppliesByUserId(userId);
      return dtos.map((e) => e.toDomain()).toList();
    } catch (_) {
      return [];
    }
  }
}
