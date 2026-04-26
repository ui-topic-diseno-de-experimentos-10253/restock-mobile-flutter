class SubscriptionPlan {
  final String name;
  final String price;
  final List<String> features;
  final bool popular;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.features,
    this.popular = false,
  });
}
