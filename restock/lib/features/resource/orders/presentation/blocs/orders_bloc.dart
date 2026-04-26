import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/core/services/excel_export_service.dart';
import 'package:restock/features/resource/inventory/domain/models/batch.dart';
import 'package:restock/features/resource/inventory/domain/models/custom_supply.dart';
import 'package:restock/features/resource/inventory/domain/repositories/inventory_repository.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';
import 'package:restock/features/resource/orders/domain/repositories/orders_repository.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_event.dart';
import 'package:restock/features/resource/orders/presentation/blocs/orders_state.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:collection/collection.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repository;
  final ProfileService profileService;
  final AuthStorage authStorage;
  final ExcelExportService excelService;
  final InventoryRepository inventoryRepository;

  OrdersBloc({
    required this.repository,
    required this.profileService,
    required this.authStorage,
    ExcelExportService? excelService,
    required this.inventoryRepository,
  })  : excelService = excelService ?? ExcelExportService(),
        super(const OrdersState()) {
    on<OrdersStarted>(_onStarted);
    on<OrdersRefreshRequested>(_onRefreshRequested);
    on<OrdersTabChanged>(_onTabChanged);
    on<OrdersSearchChanged>(_onSearchChanged);
    on<OrdersSortChanged>(_onSortChanged);
    on<OrdersStateFilterChanged>(_onFilterChanged);
    on<OrdersExportToExcel>(_onExportToExcel);
    on<OrderUpdateRequested>(_onOrderUpdateRequested);
    on<OrderStateUpdateRequested>(_onOrderStateUpdateRequested);  
  }

  // ================== CARGA INICIAL ==================

  Future<void> _loadOrdersForSupplier(
    int supplierId,
    Emitter<OrdersState> emit,
  ) async {
    print('BLoC: Loading orders for supplier $supplierId');
    emit(state.copyWith(status: Status.loading, errorMessage: null));

    try {
      final List<Order> orders =
          await repository.getOrdersBySupplierId(supplierId);

      print('BLoC: Received ${orders.length} orders from repository');

      // Cargar perfiles de los restaurantes
      final profileCache = Map<int, String>.from(state.profileCache);
      final token = await authStorage.getToken();

      if (token != null) {
        // Obtener IDs únicos de restaurantes
        final restaurantIds = orders
            .map((o) => o.adminRestaurantId)
            .toSet()
            .where((id) => !profileCache.containsKey(id));

        print('BLoC: Loading ${restaurantIds.length} restaurant profiles');

        for (final restaurantId in restaurantIds) {
          try {
            final profile =
                await profileService.getProfile(token, restaurantId);
            profileCache[restaurantId] = profile.businessName;
            print(' Loaded profile: ${profile.businessName}');
          } catch (e) {
            print('Failed to load profile for restaurant $restaurantId: $e');
            profileCache[restaurantId] = 'Restaurant #$restaurantId';
          }
        }
      }

      emit(state.copyWith(
        status: Status.success,
        allOrders: orders,
        supplierId: supplierId,
        profileCache: profileCache,
      ));

      print(' BLoC: State updated with ${state.allOrders.length} orders');
      print(' BLoC: Visible orders: ${state.visibleOrders.length}');
    } catch (e, stackTrace) {
      print('BLoC: Error loading orders: $e');
      print('BLoC StackTrace: $stackTrace');

      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStarted(
    OrdersStarted event,
    Emitter<OrdersState> emit,
  ) async {
    print(
        'BLoC: OrdersStarted event triggered with supplierId: ${event.supplierId}');
    await _loadOrdersForSupplier(event.supplierId, emit);
  }

  Future<void> _onRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final id = state.supplierId;
    print('BLoC: Refresh requested for supplierId: $id');
    if (id != null) {
      await _loadOrdersForSupplier(id, emit);
    }
  }

  // ================== UI: TABS, SEARCH, SORT, FILTER ==================

  void _onTabChanged(
    OrdersTabChanged event,
    Emitter<OrdersState> emit,
  ) {
    print('BLoC: Tab changed to ${event.tab}');
    emit(state.copyWith(currentTab: event.tab));
    print(
        'BLoC: After tab change, visible orders: ${state.visibleOrders.length}');
  }

  void _onSearchChanged(
    OrdersSearchChanged event,
    Emitter<OrdersState> emit,
  ) {
    print('BLoC: Search query: "${event.query}"');
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSortChanged(
    OrdersSortChanged event,
    Emitter<OrdersState> emit,
  ) {
    print('BLoC: Sort changed to ${event.sort}');
    emit(state.copyWith(sort: event.sort));
  }

  void _onFilterChanged(
    OrdersStateFilterChanged event,
    Emitter<OrdersState> emit,
  ) {
    print('BLoC: Filter changed to ${event.stateFilter}');
    emit(
      state.copyWith(
        stateFilter: event.stateFilter,
        clearStateFilter: event.stateFilter == null,
      ),
    );
  }

  // ================== EXPORTAR A EXCEL ==================

  Future<void> _onExportToExcel(
    OrdersExportToExcel event,
    Emitter<OrdersState> emit,
  ) async {
    print('BLoC: Starting Excel export');
    emit(state.copyWith(isExporting: true, clearExportedFilePath: true));

    try {
      // Obtener solo las órdenes del historial
      final historyOrders =
          state.allOrders.where((o) => o.state.isFinished).toList();

      if (historyOrders.isEmpty) {
        emit(state.copyWith(
          isExporting: false,
          errorMessage: 'No orders to export',
        ));
        return;
      }

      final filePath = await excelService.exportOrdersToExcel(
        historyOrders,
        state.profileCache,
      );

      if (filePath != null) {
        print('BLoC: Excel exported to: $filePath');
        emit(state.copyWith(
          isExporting: false,
          exportedFilePath: filePath,
        ));
      } else {
        print('BLoC: Failed to export Excel');
        emit(state.copyWith(
          isExporting: false,
          errorMessage: 'Failed to export file',
        ));
      }
    } catch (e) {
      print('BLoC: Error exporting Excel: $e');
      emit(state.copyWith(
        isExporting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================== ACTUALIZAR ORDEN COMPLETA ==================

  Future<void> _onOrderUpdateRequested(
    OrderUpdateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final updated = await repository.updateOrder(event.updatedOrder);
      if (updated == null) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: 'Could not update order',
        ));
        return;
      }

      final updatedList = state.allOrders
          .map((o) => o.id == updated.id ? updated : o)
          .toList();

      emit(state.copyWith(
        allOrders: updatedList,
        status: Status.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================== ACTUALIZAR SOLO STATE + SYNC INVENTARIO ==================

   Future<void> _onOrderStateUpdateRequested(
    OrderStateUpdateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final currentOrders = state.allOrders;

    Order? oldOrder;
    try {
      oldOrder = currentOrders.firstWhere((o) => o.id == event.orderId);
    } catch (_) {
      oldOrder = null;
    }

    emit(state.copyWith(status: Status.loading));

    try {
      final updated = await repository.updateOrderState(
        orderId: event.orderId,
        newState: event.newState,
        newSituation: event.newSituation,
      );

      final updatedList = currentOrders
          .map((o) => o.id == updated.id ? updated : o)
          .toList();

      emit(state.copyWith(
        allOrders: updatedList,
        status: Status.success,
      ));

      // Si pasó a DELIVERED por primera vez → sync inventario
      if (oldOrder != null &&
          oldOrder.state != OrderState.delivered &&
          updated.state == OrderState.delivered) {
        await _syncInventoryWithDeliveredOrder(updated);
      }
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================== SYNC INVENTARIO ==================

Future<void> _syncInventoryWithDeliveredOrder(Order order) async {
    final supplierId = order.supplierId;
    final restaurantId = order.adminRestaurantId;

    // 1) Cargar inventario de proveedor y restaurante
    final supplierBatches =
        await inventoryRepository.getBatchesByUser(supplierId);
    final restaurantBatches =
        await inventoryRepository.getBatchesByUser(restaurantId);
    final restaurantCustomSupplies =
        await inventoryRepository.getCustomSuppliesByUser(restaurantId);

    for (final item in order.batchItems) {
      // solo items marcados como aceptados
      if (!item.accepted) continue;

      final qty = item.quantity;

      // ---------- 1. Descontar del proveedor ----------
      Batch? supplierBatch;
      for (final b in supplierBatches) {
        if (b.id == item.batchId && b.userId == supplierId) {
          supplierBatch = b;
          break;
        }
      }

      if (supplierBatch != null) {
        final newStock = (supplierBatch.stock - qty).clamp(0, double.infinity);
        await inventoryRepository.updateBatch(
            supplierBatch.copyWith(stock: newStock.toDouble()),
        );
      }

      // ---------- 2. Sumar al restaurante ----------
      final supplyId = item.batch?.customSupply?.supply?.id;
      if (supplyId == null) continue;

      // 2.1 Buscar batch existente del restaurante con ese supplyId
      Batch? restaurantBatch;
      for (final b in restaurantBatches) {
        if (b.customSupply?.supply?.id == supplyId &&
            b.userId == restaurantId) {
          restaurantBatch = b;
          break;
        }
      }

      if (restaurantBatch != null) {
        final newStock = restaurantBatch.stock + qty;
        await inventoryRepository.updateBatch(
          restaurantBatch.copyWith(stock: newStock),
        );
        continue; // ya sumamos, siguiente item
      }

      // 2.2 No hay batch → buscar CustomSupply
      CustomSupply? cs;
      for (final c in restaurantCustomSupplies) {
        if (c.supply?.id == supplyId && c.userId == restaurantId) {
          cs = c;
          break;
        }
      }

      if (cs != null) {
        final newBatch = Batch(
          id: '', // lo genera el backend
          userId: restaurantId,
          customSupplyId: cs.id,
          stock: qty,
          expirationDate: item.batch?.expirationDate ??
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );

        await inventoryRepository.createBatch(newBatch);
      }
    }
  }

}
