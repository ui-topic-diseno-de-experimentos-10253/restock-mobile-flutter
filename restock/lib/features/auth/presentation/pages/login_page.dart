import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/presentation/blocs/login_bloc.dart';
import 'package:restock/features/auth/presentation/blocs/login_event.dart';
import 'package:restock/features/auth/presentation/blocs/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:restock/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  final Color primaryGreen = const Color(0xFF1B5E20); // Verde medio oscuro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case Status.success:
              // Verificar suscripción: 0 = sin suscripción, 1 = anual, 2 = semestral
              if (state.userSubscription == 0) {
                // Sin suscripción, ir a página de planes
                Navigator.pushReplacementNamed(context, '/subscriptions');
              } else {
                // Con suscripción, ir a home
                Navigator.pushReplacementNamed(context, '/home');
              }
              break;

            case Status.failure:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Unknown error')),
              );
              break;

            default:
          }
        },
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome to',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'Restock Suppliers',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    TextField(
                      onChanged: (value) =>
                          context.read<LoginBloc>().add(OnEmailChanged(email: value)),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      onChanged: (value) => context
                          .read<LoginBloc>()
                          .add(OnPasswordChanged(password: value)),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
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
                      obscureText: !_isPasswordVisible,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryGreen,
                        ),
                        onPressed: () =>
                            context.read<LoginBloc>().add(const Login()),
                        child: const Text('Sign In With Restock'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ),

            BlocSelector<LoginBloc, LoginState, bool>(
              selector: (state) => state.status == Status.loading,
              builder: (context, isLoading) {
                if (isLoading) {
                  return Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
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

