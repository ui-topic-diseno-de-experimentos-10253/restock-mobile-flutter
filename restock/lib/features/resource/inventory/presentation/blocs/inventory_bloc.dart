 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/resource/inventory/domain/repositories/inventory_repository.dart';

import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository repository;

  InventoryBloc({required this.repository}) : super(const InventoryState()) {
    on<InventoryLoadRequested>(_onLoadInventory);
    on<CreateBatchEvent>(_onCreateBatch);
    on<UpdateBatchEvent>(_onUpdateBatch);
    on<DeleteBatchEvent>(_onDeleteBatch);
    on<CreateCustomSupplyEvent>(_onCreateCustomSupply);
    on<UpdateCustomSupplyEvent>(_onUpdateCustomSupply);
    on<DeleteCustomSupplyEvent>(_onDeleteCustomSupply);
    on<InventoryClearRequested>((event, emit) {
      emit(const InventoryState()); // estado vacío
    });
  }

  Future<void> _onLoadInventory(
    InventoryLoadRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final supplies = await repository.getSupplies();
      final customSupplies = await repository.getCustomSuppliesByUserId();
      final batches = await repository.getBatchesByUserId();

      emit(
        state.copyWith(
          supplies: supplies,
          customSupplies: customSupplies,
          batches: batches,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateBatch(
    CreateBatchEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.createBatch(event.batch);
    add(const InventoryLoadRequested());
  }

  Future<void> _onUpdateBatch(
    UpdateBatchEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.updateBatch(event.batch);
    add(const InventoryLoadRequested());
  }

  Future<void> _onDeleteBatch(
    DeleteBatchEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.deleteBatch(event.id);
    add(const InventoryLoadRequested());
  }

  Future<void> _onCreateCustomSupply(
    CreateCustomSupplyEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.createCustomSupply(event.supply);
    add(const InventoryLoadRequested());
  }

  Future<void> _onUpdateCustomSupply(
    UpdateCustomSupplyEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.updateCustomSupply(event.supply);
    add(const InventoryLoadRequested());
  }

  Future<void> _onDeleteCustomSupply(
    DeleteCustomSupplyEvent event,
    Emitter<InventoryState> emit,
  ) async {
    await repository.deleteCustomSupply(event.id);
    add(const InventoryLoadRequested());
  }
}
