// lib/features/subscriptions/presentation/blocs/subscription_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/subscriptions/data/remote/subscription_service.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_event.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService service;
  final AuthStorage storage;

  SubscriptionBloc({
    required this.service,
    required this.storage,
  }) : super(const SubscriptionState()) {
    on<UpdateSubscription>(_onUpdateSubscription);
  }

  FutureOr<void> _onUpdateSubscription(
    UpdateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    try {
      final userId = await storage.getUserId();
      final token = await storage.getToken();

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      await service.updateSubscription(
        userId: userId,
        token: token,
        planType: event.planType,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        message: e.toString(),
      ));
    }
  }
}
