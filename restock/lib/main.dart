
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/services/fcm_manager.dart';
import 'package:restock/core/services/push_token_service.dart';
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
import 'package:restock/features/home/presentation/pages/main_navigation_screen.dart';

// INVENTORY
import 'package:restock/features/resource/inventory/data/remote/inventory_service.dart';
import 'package:restock/features/resource/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/pages/inventory_detail_page.dart';
import 'package:restock/features/resource/inventory/presentation/pages/inventory_page.dart';
import 'package:restock/features/resource/inventory/presentation/pages/supply_detail_by_id_page.dart';

// SUBSCRIPTIONS
import 'package:restock/features/subscriptions/data/remote/subscription_service.dart';
import 'package:restock/features/subscriptions/presentation/blocs/subscription_bloc.dart';
import 'package:restock/features/subscriptions/presentation/pages/subscription_plans_page.dart';
import 'package:restock/features/subscriptions/presentation/pages/payment_page.dart';

/// Global navigator key – used by [FcmManager] to navigate from push notifications
/// without requiring a BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before anything else.
  await Firebase.initializeApp();

  final authService = AuthService();
  final authStorage = AuthStorage();
  final pushTokenService = PushTokenService();

  // Create and initialize the FCM manager.
  final fcmManager = FcmManager(
    pushTokenService: pushTokenService,
    navigatorKey: navigatorKey,
  );
  await fcmManager.initialize();

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
            fcmManager: fcmManager,
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
      title: 'Restock Suppliers',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF4F8A5B),
          background: const Color(0xFFF9FBF9),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBF9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          hintStyle: const TextStyle(color: Colors.black38),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login':         (_) => const LoginPage(),
        '/home':          (_) => const MainNavigationScreen(),
        '/inventory':     (_) => const InventoryPage(),
        '/subscriptions': (_) => const SubscriptionPlansPage(),
        '/payment':       (_) => const PaymentPage(),
        '/alerts':        (_) => const AlertsPage(),
        // ── Deep-link routes from push notifications ──────────────────
        '/inventory_detail': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments
              as Map<String, dynamic>?;
          final batchId = args?['batchId'] as String? ?? '';
          return InventoryDetailPage(batchId: batchId);
        },
        '/supply_detail_by_id': (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments
              as Map<String, dynamic>?;
          final customSupplyId = args?['customSupplyId'] as String? ?? '';
          return SupplyDetailByIdPage(customSupplyId: customSupplyId);
        },
      },
    );
  }
}
