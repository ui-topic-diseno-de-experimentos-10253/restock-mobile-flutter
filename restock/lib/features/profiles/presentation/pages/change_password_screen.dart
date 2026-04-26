import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_event.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Change password'),
      ),
      body: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.status == Status.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Password
                TextField(
                  controller: _currentPasswordController,
                  enabled: !isLoading,
                  obscureText: !state.currentPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.currentPasswordError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.currentPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        context.read<ChangePasswordBloc>().add(
                              const ToggleCurrentPasswordVisibility(),
                            );
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ChangePasswordBloc>().add(
                          OnCurrentPasswordChanged(currentPassword: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // New Password
                TextField(
                  controller: _newPasswordController,
                  enabled: !isLoading,
                  obscureText: !state.newPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.newPasswordError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.newPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        context.read<ChangePasswordBloc>().add(
                              const ToggleNewPasswordVisibility(),
                            );
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ChangePasswordBloc>().add(
                          OnNewPasswordChanged(newPassword: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm New Password
                TextField(
                  controller: _confirmPasswordController,
                  enabled: !isLoading,
                  obscureText: !state.confirmPasswordVisible,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.confirmPasswordError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        context.read<ChangePasswordBloc>().add(
                              const ToggleConfirmPasswordVisibility(),
                            );
                      },
                    ),
                  ),
                  onChanged: (value) {
                    context.read<ChangePasswordBloc>().add(
                          OnConfirmPasswordChanged(confirmPassword: value),
                        );
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<ChangePasswordBloc>().add(
                                  const ChangePassword(),
                                );
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('SAVE CHANGES'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
