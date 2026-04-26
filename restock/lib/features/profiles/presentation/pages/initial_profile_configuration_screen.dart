import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_state.dart';
import 'package:restock/features/profiles/presentation/widgets/business_info_step.dart';
import 'package:restock/features/profiles/presentation/widgets/personal_info_step.dart';
import 'package:restock/features/profiles/presentation/widgets/subscription_step.dart';

class InitialProfileConfigurationScreen extends StatelessWidget {
  const InitialProfileConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InitialConfigBloc, InitialConfigState>(
      listener: (context, state) {
        if (state.status == Status.success) {
          // Navigate to home
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else if (state.status == Status.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Progress Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Step 1
                          _StepIndicator(
                            number: 1,
                            label: 'Personal',
                            isActive: state.currentStep == 0,
                            isCompleted: state.currentStep > 0,
                          ),
                          // Connector 1-2
                          Expanded(
                            child: Container(
                              height: 2,
                              color: state.currentStep > 0
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          // Step 2
                          _StepIndicator(
                            number: 2,
                            label: 'Business',
                            isActive: state.currentStep == 1,
                            isCompleted: state.currentStep > 1,
                          ),
                          // Connector 2-3
                          Expanded(
                            child: Container(
                              height: 2,
                              color: state.currentStep > 1
                                  ? const Color(0xFF1B5E20)
                                  : Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          // Step 3
                          _StepIndicator(
                            number: 3,
                            label: 'Subscription',
                            isActive: state.currentStep == 2,
                            isCompleted: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (state.currentStep + 1) / 3,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1B5E20),
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: state.status == Status.loading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF1B5E20),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Setting up your profile...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : IndexedStack(
                          index: state.currentStep,
                          children: const [
                            PersonalInfoStep(),
                            BusinessInfoStep(),
                            SubscriptionStep(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? const Color(0xFF1B5E20)
                : Colors.grey.shade300,
            border: Border.all(
              color: isActive
                  ? const Color(0xFF1B5E20)
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? const Color(0xFF1B5E20)
                : Colors.black54,
          ),
        ),
      ],
    );
  }
}
