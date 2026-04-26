// lib/features/subscriptions/presentation/blocs/subscription_event.dart
abstract class SubscriptionEvent {
  const SubscriptionEvent();
}

class UpdateSubscription extends SubscriptionEvent {
  final int planType;

  const UpdateSubscription(this.planType);
}
