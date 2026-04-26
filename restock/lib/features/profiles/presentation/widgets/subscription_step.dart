import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_event.dart';
import 'package:restock/features/subscriptions/domain/models/subscription_plan.dart';

class SubscriptionStep extends StatelessWidget {
  const SubscriptionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      const SubscriptionPlan(
        name: "Anual Plan",
        price: "S/. 39.99 / monthly",
        features: [
          "Automated inventory management",
          "Order and purchase control",
          "Reporting and analytics",
          "Critical stock notifications",
          "Integration with suppliers",
        ],
        popular: true,
      ),
      const SubscriptionPlan(
        name: "Semester Plan",
        price: "S/. 49.99 / monthly",
        features: [
          "Automated inventory management",
          "Order and purchase control",
          "Reporting and analytics",
          "Critical stock notifications",
          "Integration with suppliers",
        ],
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Icon(
                  Icons.workspace_premium_outlined,
                  size: 64,
                  color: Color(0xFF1B5E20),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Your Plan',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a subscription plan to unlock all features',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 32),

                // Subscription Plans
                ...plans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;
                  final planType = index + 1; // 1 = Anual, 2 = Semester

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SubscriptionPlanCard(
                      plan: plan,
                      onSubscribe: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/payment',
                          arguments: planType,
                        );
                        // If payment was successful
                        if (result == true && context.mounted) {
                          context
                              .read<InitialConfigBloc>()
                              .add(const SubscriptionCompleted());
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom Navigation
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<InitialConfigBloc>()
                          .add(const BackToBusinessInfo());
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text(
                      'Back',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      side: const BorderSide(color: Color(0xFF1B5E20)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: TextButton(
                    onPressed: () {
                      context
                          .read<InitialConfigBloc>()
                          .add(const SkipSubscription());
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onSubscribe;

  const _SubscriptionPlanCard({
    required this.plan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: plan.popular
            ? const BorderSide(color: Color(0xFF1B5E20), width: 2)
            : BorderSide.none,
      ),
      elevation: plan.popular ? 8 : 4,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.price,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF1B5E20),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onSubscribe,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SUBSCRIBE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (plan.popular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B5E20),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
