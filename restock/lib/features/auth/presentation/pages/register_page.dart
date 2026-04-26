import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/auth/presentation/blocs/register_bloc.dart';
import 'package:restock/features/auth/presentation/blocs/register_event.dart';
import 'package:restock/features/auth/presentation/blocs/register_state.dart';
import 'package:restock/features/profiles/data/remote/business_update_service.dart';
import 'package:restock/features/profiles/data/remote/profile_update_service.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_bloc.dart';
import 'package:restock/features/profiles/presentation/pages/initial_profile_configuration_screen.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;

  final Color primaryGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            // Navigate to initial profile configuration
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => InitialConfigBloc(
                    profileService: ProfileUpdateService(),
                    businessService: BusinessUpdateService(),
                    storage: AuthStorage(),
                  ),
                  child: const InitialProfileConfigurationScreen(),
                ),
              ),
            );
          } else if (state.status == Status.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Error desconocido')),
            );
          }
        },
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Your Restock Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      onChanged: (v) => context
                          .read<RegisterBloc>()
                          .add(OnUsernameChanged(username: v)),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      onChanged: (v) => context
                          .read<RegisterBloc>()
                          .add(OnPasswordChangedRegister(password: v)),
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _isPasswordVisible = !_isPasswordVisible),
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
                        onPressed: () => context
                            .read<RegisterBloc>()
                            .add(const RegisterSubmitted()),
                        child: const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ],
                ),
              ),
            ),

            BlocSelector<RegisterBloc, RegisterState, bool>(
              selector: (state) => state.status == Status.loading,
              builder: (context, isLoading) {
                if (isLoading) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
