import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/core/services/cloudinary_service.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/common/placeholder_screen.dart';
import 'package:restock/features/home/presentation/widgets/quick_action_card.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_event.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_state.dart';
import 'package:restock/features/profiles/presentation/pages/profile_detail_screen.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_bloc.dart';
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_event.dart';
import 'package:restock/features/resource/orders/data/remote/orders_service.dart';
import 'package:restock/features/resource/orders/data/repositories/orders_repository_impl.dart';
import 'package:restock/features/resource/orders/presentation/pages/orders_page.dart';
import 'package:restock/features/resource/orders/presentation/pages/supplier_orders_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(
      service: ProfileService(),
      storage: AuthStorage(),
      cloudinaryService: CloudinaryService(),
    )..add(const LoadProfile());
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  void _goPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _profileBloc,
          child: const ProfileDetailScreen(),
        ),
      ),
    );
    // Reload profile when returning from profile screen
    if (mounted) {
      _profileBloc.add(const LoadProfile());
    }
  }

  Future<void> _goToOrders(BuildContext context) async {
    final authStorage = AuthStorage();
    final supplierId = await authStorage.getUserId(); // o el método que uses
  
    if (!mounted) return;
  
    if (supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get supplier id')),
      );
      return;
    }
  
    final ordersRepository = OrdersRepositoryImpl(
      service: OrdersService(),
    );
  
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierOrdersPage(
          repository: ordersRepository,
          supplierId: supplierId,
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color.fromRGBO(92, 164, 104, 1);

    return BlocProvider.value(
      value: _profileBloc,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 140, // ajusta el tamaño según necesites
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // INVENTORY -> va a la ruta real
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Inventory"),
                onTap: () {
                  Navigator.pop(context); // cierra drawer
                  Navigator.pushNamed(context, '/inventory');
                },
              ),

            // Otras opciones siguen con placeholder
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Orders"),
              onTap: () {
                Navigator.pop(context);
                _goToOrders(context);
              },
            ),

              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text("Profile"),
                onTap: () {
                  Navigator.pop(context); // cierra drawer
                  _navigateToProfile(context);
                },
              ),

              const Spacer(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await AuthStorage().clear(); // borra userId y token

                  context.read<InventoryBloc>().add(
                    const InventoryClearRequested(),
                  ); // limpiamos el estado

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text("Restock"),
          centerTitle: true,
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () => _navigateToProfile(context),
                tooltip: 'Profile',
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and Welcome Message
                  Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => _navigateToProfile(context),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: profileState.profile?.avatar != null
                                ? Colors.grey.shade200
                                : primaryGreen.withValues(alpha: 0.2),
                            border: Border.all(color: primaryGreen, width: 2),
                          ),
                          child:
                              profileState.profile?.avatar != null &&
                                  profileState.profile!.avatar!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileState.profile!.avatar!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildInitialsAvatar(
                                        profileState.profile?.firstName ?? '',
                                        profileState.profile?.lastName ?? '',
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                  ),
                                )
                              : _buildInitialsAvatar(
                                  profileState.profile?.firstName ?? '',
                                  profileState.profile?.lastName ?? '',
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Welcome Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back,",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.black54),
                            ),
                            if (profileState.status == Status.loading &&
                                profileState.profile == null)
                              Container(
                                height: 32,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            else
                              Text(
                                profileState.profile?.firstName ?? "Supplier",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.inventory,
                          title: "Inventory",
                          subtitle: "Track supplies",
                          onTap: () =>
                              Navigator.pushNamed(context, '/inventory'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                       child: QuickActionCard(
                         icon: Icons.shopping_cart,
                         title: "Orders",
                         subtitle: "Manage orders",
                         onTap: () => _goToOrders(context),
                       ),
                      ),
                    ],
                  ),
                  // Espacio vertical entre filas
                  const SizedBox(height: 16),

                  // 2. SEGUNDA FILA DE ACCIONES RÁPIDAS (Alerts)
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          // Ícono apropiado para Alertas/Notificaciones
                          icon: Icons.notifications_active,
                          title: "Alerts",
                          subtitle: "View pending issues",
                          // Usamos la ruta que definimos antes
                          onTap: () => Navigator.pushNamed(context, '/alerts'),
                        ),
                      ),
                      // Rellenar el espacio restante con un widget vacío (o una tarjeta de suscripción/placeholder)
                      const SizedBox(width: 16),
                      const Expanded(
                        child: SizedBox.shrink(), // Deja este espacio vacío
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Your Business",
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.trending_up,
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Start managing your store, inventory and sales to see insights here.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String firstName, String lastName) {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final initials = '$firstInitial$lastInitial';

    return Center(
      child: Text(
        initials.isNotEmpty ? initials : 'S',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }
}
