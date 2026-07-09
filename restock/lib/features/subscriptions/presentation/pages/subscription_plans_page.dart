// lib/features/subscriptions/presentation/pages/subscription_plans_page.dart
import 'package:flutter/material.dart';
import 'package:restock/features/subscriptions/domain/models/subscription_plan.dart';

class SubscriptionPlansPage extends StatelessWidget {
  const SubscriptionPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final plans = [
      const SubscriptionPlan(
        name: "Annual Plan",
        price: "S/. 39.99 / mo",
        features: [
          "Automated inventory cataloging",
          "Order fulfillment & tracking",
          "Reporting and insights overview",
          "Real-time low stock notifications",
          "Direct connection with restaurants",
        ],
        popular: true,
      ),
      const SubscriptionPlan(
        name: "Semester Plan",
        price: "S/. 49.99 / mo",
        features: [
          "Automated inventory cataloging",
          "Order fulfillment & tracking",
          "Reporting and insights overview",
          "Real-time low stock notifications",
          "Direct connection with restaurants",
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Plans"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Subtle Gradient Background Accent
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primaryColor.withOpacity(0.06),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Header Intro
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Grow Your Delivery Business",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Unlock premium tools to supply local restaurants",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Plans
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
            ],
          ),
        ],
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: plan.popular ? primaryColor : Colors.black.withOpacity(0.06),
          width: plan.popular ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: plan.popular ? primaryColor.withOpacity(0.06) : Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.popular) ...[
                    const SizedBox(height: 8),
                  ],
                  // Plan Title
                  Text(
                    plan.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: plan.popular ? primaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Plan Pricing
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        plan.price.split(' ').first,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plan.price.replaceAll(plan.price.split(' ').first, '').trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Features separator
                  const Divider(height: 1, color: Color(0xFFF1F1F1)),
                  const SizedBox(height: 20),

                  // Features List
                  ...plan.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: primaryColor,
                                size: 12.0,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                feature,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  
                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onSubscribeClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.popular ? primaryColor : Colors.grey.shade100,
                        foregroundColor: plan.popular ? Colors.white : Colors.black87,
                        elevation: plan.popular ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        plan.popular ? "Get Started Now" : "Choose Plan",
                        style: const TextStyle(
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
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_outline, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "BEST VALUE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
