import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/home/presentation/pages/home_page.dart';
import 'package:restock/features/profiles/data/remote/profile_service.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_event.dart';
import 'package:restock/features/profiles/presentation/pages/profile_detail_screen.dart';
import 'package:restock/features/resource/inventory/presentation/pages/inventory_page.dart';
import 'package:restock/features/resource/orders/data/remote/orders_service.dart';
import 'package:restock/features/resource/orders/data/repositories/orders_repository_impl.dart';
import 'package:restock/features/resource/orders/presentation/pages/supplier_orders_page.dart';
import 'package:restock/core/services/cloudinary_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int _supplierId = 0;
  bool _loading = true;
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc(
      service: ProfileService(),
      storage: AuthStorage(),
      cloudinaryService: CloudinaryService(),
    )..add(const LoadProfile());
    _loadSupplierId();
  }

  @override
  void dispose() {
    _profileBloc.close();
    super.dispose();
  }

  Future<void> _loadSupplierId() async {
    final id = await AuthStorage().getUserId();
    if (mounted) {
      setState(() {
        _supplierId = id ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return BlocProvider<ProfileBloc>.value(
      value: _profileBloc,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const HomePage(),
            const InventoryPage(),
            SupplierOrdersPage(
              repository: OrdersRepositoryImpl(service: OrdersService()),
              supplierId: _supplierId,
            ),
            const ProfileDetailScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, "Home"),
              _buildNavItem(1, Icons.inventory_2_outlined, Icons.inventory_2, "Catalog"),
              _buildNavItem(2, Icons.shopping_bag_outlined, Icons.shopping_bag, "Orders"),
              _buildNavItem(3, Icons.person_outline, Icons.person, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? primaryColor : Colors.black54,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
