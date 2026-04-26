// lib/features/resource/inventory/presentation/blocs/inventory_state.dart
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/models/supply.dart';

class InventoryState {
  final List<Supply> supplies;
  final List<CustomSupply> customSupplies;
  final List<Batch> batches;
  final bool loading;
  final String? error;

  const InventoryState({
    this.supplies = const [],
    this.customSupplies = const [],
    this.batches = const [],
    this.loading = false,
    this.error,
  });

  InventoryState copyWith({
    List<Supply>? supplies,
    List<CustomSupply>? customSupplies,
    List<Batch>? batches,
    bool? loading,
    String? error,
  }) {
    return InventoryState(
      supplies: supplies ?? this.supplies,
      customSupplies: customSupplies ?? this.customSupplies,
      batches: batches ?? this.batches,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
