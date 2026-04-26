// lib/features/subscriptions/presentation/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_bloc.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_event.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_state.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _emailController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _countryController = TextEditingController(text: "United States");
  final _zipController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _cardholderNameController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planType = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
    final planName = planType == 1 ? "Anual Plan" : "Semester Plan";
    final planPrice =
        planType == 1 ? "S/. 39.99 / monthly" : "S/. 49.99 / monthly";

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          // Redirigir a home después del pago exitoso
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == Status.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Payment failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == Status.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(planName),
          ),
          body: Container(
            color: const Color(0xFFF5F5F5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Plan Info Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          Text(
                            planPrice,
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8.0),

                  // Card Number Field
                  TextField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: "Card information",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: Icon(Icons.credit_card),
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Expiry Date and CVC Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: "MM / YY",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _cvcController,
                          decoration: const InputDecoration(
                            labelText: "CVC",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          enabled: !isLoading,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // Cardholder Name Field
                  TextField(
                    controller: _cardholderNameController,
                    decoration: const InputDecoration(
                      labelText: "Cardholder name",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8.0),

                  // Country Field
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: "Country or region",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 8.0),

                  // ZIP Field
                  TextField(
                    controller: _zipController,
                    decoration: const InputDecoration(
                      labelText: "ZIP",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context
                                  .read<SubscriptionBloc>()
                                  .add(UpdateSubscription(planType));
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24.0,
                              height: 24.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text(
                              "Pay",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
