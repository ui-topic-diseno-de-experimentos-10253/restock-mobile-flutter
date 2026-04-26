// lib/features/subscriptions/presentation/blocs/subscription_state.dart
import 'package:restock/core/enums/status.dart';

class SubscriptionState {
  final Status status;
  final String? message;

  const SubscriptionState({
    this.status = Status.initial,
    this.message,
  });

  SubscriptionState copyWith({
    Status? status,
    String? message,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
