// lib/features/subscriptions/presentation/pages/subscription_plans_page.dart
import 'package:flutter/material.dart';
import 'package:restock/features/subscriptions/domain/models/subscription_plan.dart';

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscriptions"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            // index 0 = Anual (planType 1), index 1 = Semester (planType 2)
            final planType = index + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _SubscriptionPlanItem(
                plan: plans[index],
                onSubscribeClick: () {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: planType,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubscriptionPlanItem extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onSubscribeClick;

  const _SubscriptionPlanItem({
    required this.plan,
    this.onSubscribeClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  plan.price,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16.0),
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Color(0xFF4CAF50),
                            size: 16.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSubscribeClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "SUBSCRIBE",
                      style: TextStyle(
                        color: Colors.white,
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
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: const Text(
                  "POPULAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
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
