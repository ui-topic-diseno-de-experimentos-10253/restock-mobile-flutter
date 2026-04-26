
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/alerts/data/remote/alert_service.dart';
import 'package:restock/features/alerts/data/repositories/alert_repository_impl.dart';
import 'package:restock/features/alerts/presentation/blocs/alert_bloc.dart';
import 'package:restock/features/alerts/presentation/pages/alerts_page.dart';

import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/auth/data/remote/auth_service.dart';
import 'package:restock/features/auth/presentation/blocs/login_bloc.dart';
import 'package:restock/features/auth/presentation/blocs/register_bloc.dart';
import 'package:restock/features/auth/presentation/pages/login_page.dart';
import 'package:restock/features/home/presentation/pages/home_page.dart';

// INVENTORY
import 'package:restock/features/resource/inventory/data/remote/inventory_service.dart';
import 'package:restock/features/resource/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/pages/inventory_page.dart';

// SUBSCRIPTIONS
import 'package:restock/features/subscriptions/data/remote/subscription_service.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_bloc.dart';
import 'package:restock/features/subscriptions/presentation/pages/subscription_plans_page.dart';
import 'package:restock/features/subscriptions/presentation/pages/payment_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final authStorage = AuthStorage();

  final inventoryService = InventoryService();

  final alertService = AlertService();
  final alertRepository = AlertRepositoryImpl(
    service: alertService,
    getUserId: () async {
      final id = await authStorage.getUserId();
      if (id == null) {
        throw Exception('No hay usuario logueado'); 
      }
      return id;
    },
  );
  
  final inventoryRepository = InventoryRepositoryImpl(
    service: inventoryService,
    getUserId: () async {
      final id = await authStorage.getUserId();
      if (id == null) {
        throw Exception('No hay usuario logueado');
      }
      return id;
    },
  );

  final subscriptionService = SubscriptionService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginBloc(
            service: authService,
            storage: authStorage,
          ),
        ),
        BlocProvider(
          create: (_) => RegisterBloc(
            service: authService,
            storage: authStorage,
          ),
        ),
        BlocProvider(
          create: (_) => InventoryBloc(repository: inventoryRepository),
        ),
        BlocProvider(
          create: (_) => SubscriptionBloc(
            service: subscriptionService,
            storage: authStorage,
          ),
        ),
        BlocProvider(
          create: (_) => AlertBloc(repository: alertRepository),
        ),
      ],
      child: const RestockApp(),
    ),
  );
}

class RestockApp extends StatelessWidget {
  const RestockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restock',
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/inventory': (_) => const InventoryPage(),
        '/subscriptions': (_) => const SubscriptionPlansPage(),
        '/payment': (_) => const PaymentPage(),
        '/alerts': (_) => const AlertsPage(),
      },
    );
  }
}
