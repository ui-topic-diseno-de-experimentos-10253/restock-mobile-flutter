import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/alerts/domain/repositories/alert_repository.dart';

import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository repository;

  AlertBloc({required this.repository}) : super(const AlertState()) {
    on<AlertsLoadRequested>(_onLoadAlerts);
    on<AlertsClearRequested>((event, emit) {
      emit(const AlertState()); 
    });
  }

  Future<void> _onLoadAlerts(
    AlertsLoadRequested event,
    Emitter<AlertState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final supplierAlerts = await repository.getAlertsBySupplier();
      final adminAlerts = await repository.getAlertsByRestaurantAdmin();
      
      emit(
        state.copyWith(
          supplierAlerts: supplierAlerts,
          adminAlerts: adminAlerts,
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}