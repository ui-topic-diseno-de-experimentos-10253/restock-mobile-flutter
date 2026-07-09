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
import 'package:restock/features/resource/inventory/presentation/blocs/inventory_state.dart';
import 'package:restock/features/resource/orders/data/remote/orders_service.dart';
import 'package:restock/features/resource/orders/data/repositories/orders_repository_impl.dart';
import 'package:restock/features/resource/orders/presentation/pages/orders_page.dart';
import 'package:restock/features/resource/orders/presentation/pages/supplier_orders_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    final profileBloc = context.read<ProfileBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileBloc,
          child: const ProfileDetailScreen(),
        ),
      ),
    );
    profileBloc.add(const LoadProfile());
  }

  Future<void> _goToOrders(BuildContext context) async {
    final authStorage = AuthStorage();
    final supplierId = await authStorage.getUserId();
  
    if (supplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get supplier id')),
      );
      return;
    }
  
    final ordersRepository = OrdersRepositoryImpl(
      service: OrdersService(),
    );
  
    if (context.mounted) {
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
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "RESTOCK SUPPLIERS",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _navigateToProfile(context),
          ),
        ],
      ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            // Determine custom time-based greeting
            final hour = DateTime.now().hour;
            final greeting = hour < 12
                ? "Good morning"
                : hour < 18
                    ? "Good afternoon"
                    : "Good evening";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Welcome Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: () => _navigateToProfile(context),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: profileState.profile?.avatar != null &&
                                    profileState.profile!.avatar!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      profileState.profile!.avatar!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildInitialsAvatar(
                                        profileState.profile?.firstName ?? '',
                                        profileState.profile?.lastName ?? '',
                                      ),
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
                                "$greeting,",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (profileState.status == Status.loading &&
                                  profileState.profile == null)
                                Container(
                                  height: 24,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                )
                              else
                                Text(
                                  profileState.profile?.firstName ?? "Supplier Partner",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title
                  Text(
                    "Quick Operations",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.inventory_2_outlined,
                          title: "Catalog",
                          subtitle: "Custom supplies",
                          onTap: () => Navigator.pushNamed(context, '/inventory'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.shopping_bag_outlined,
                          title: "Orders",
                          subtitle: "Manage requests",
                          onTap: () => _goToOrders(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.notifications_none_outlined,
                          title: "Alerts",
                          subtitle: "Critical events",
                          onTap: () => Navigator.pushNamed(context, '/alerts'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.card_membership_outlined,
                          title: "Subscription",
                          subtitle: "View current plan",
                          onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Live Insights Section (Bloc Integration)
                  Text(
                    "Insights Overview",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  BlocBuilder<InventoryBloc, InventoryState>(
                    builder: (context, invState) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor.withOpacity(0.04), primaryColor.withOpacity(0.08)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Active Inventory Stats",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Icon(Icons.analytics_outlined, color: primaryColor),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  theme,
                                  "${invState.customSupplies.length}",
                                  "Products",
                                  Icons.apps_outlined,
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: primaryColor.withOpacity(0.2),
                                ),
                                _buildStatItem(
                                  theme,
                                  "${invState.batches.length}",
                                  "Active Batches",
                                  Icons.layers_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          color: Colors.white,
        ),
      ),
    );
  }
}
