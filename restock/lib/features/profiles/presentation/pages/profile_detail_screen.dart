import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/business_update_service.dart';
import 'package:restock/features/profiles/data/remote/category_service.dart';
import 'package:restock/features/profiles/data/remote/password_service.dart';
import 'package:restock/features/profiles/data/remote/profile_update_service.dart';
import 'package:restock/features/profiles/presentation/blocs/change_password_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_event.dart';
import 'package:restock/features/profiles/presentation/blocs/profile_state.dart';
import 'package:restock/features/profiles/presentation/pages/change_password_screen.dart';
import 'package:restock/features/profiles/presentation/pages/edit_business_data_screen.dart';
import 'package:restock/features/profiles/presentation/pages/edit_personal_data_screen.dart';
import 'package:restock/features/profiles/presentation/widgets/avatar_picker.dart';
import 'package:restock/features/profiles/presentation/widgets/category_chips.dart';
import 'package:restock/features/profiles/presentation/widgets/info_card.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == Status.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == Status.loading && state.profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == Status.failure && state.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Failed to load profile',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfile());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Avatar
                AvatarPicker(
                  avatarUrl: profile.avatar,
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  isLoading: state.isUploadingAvatar,
                  onImageSelected: (imageFile) {
                    context.read<ProfileBloc>().add(
                          UpdateAvatar(imageFile: imageFile),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Full name
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Username
                if (state.username != null && state.username!.isNotEmpty)
                  Text(
                    '@${state.username}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Personal Information Card
                InfoCard(
                  headerIcon: Icons.person,
                  headerTitle: 'Personal Information',
                  onEdit: () => _navigateToEditPersonalData(context, profile),
                  items: [
                    InfoItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: profile.email,
                    ),
                    InfoItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: profile.phone,
                    ),
                    InfoItem(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: profile.address,
                    ),
                  ],
                ),

                // Business Information Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 24,
                              color: Color.fromRGBO(92, 164, 104, 1)
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Business Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToEditBusinessData(context, profile),
                              tooltip: 'Edit',
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _InfoItemWidget(
                          item: InfoItem(
                            icon: Icons.store,
                            label: 'Company Name',
                            value: profile.businessName,
                          ),
                        ),
                        _InfoItemWidget(
                          item: InfoItem(
                            icon: Icons.location_city,
                            label: 'Company Address',
                            value: profile.businessAddress,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:  Color.fromRGBO(92, 164, 104, 1)
                                    ),
                              ),
                              const SizedBox(height: 8),
                              CategoryChips(categories: profile.categories),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Change Password Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _navigateToChangePassword(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            size: 24,
                            color: Color.fromRGBO(92, 164, 104, 1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Change Password',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color:  Color.fromRGBO(92, 164, 104, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Delete Account Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDeleteAccount(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              context.read<ProfileBloc>().add(const Logout());
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              ); // Navigate to login and clear stack
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              context.read<ProfileBloc>().add(const DeleteAccount());
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditPersonalData(
    BuildContext context,
    profile,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditPersonalDataBloc(
            service: ProfileUpdateService(),
            storage: AuthStorage(),
          ),
          child: EditPersonalDataScreen(profile: profile),
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ProfileBloc>().add(const LoadProfile());
    }
  }

  Future<void> _navigateToEditBusinessData(
    BuildContext context,
    profile,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => EditBusinessDataBloc(
            businessService: BusinessUpdateService(),
            categoryService: CategoryService(),
            storage: AuthStorage(),
          ),
          child: EditBusinessDataScreen(profile: profile),
        ),
      ),
    );

    if (result == true && context.mounted) {
      context.read<ProfileBloc>().add(const LoadProfile());
    }
  }

  Future<void> _navigateToChangePassword(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChangePasswordBloc(
            service: PasswordService(),
            storage: AuthStorage(),
          ),
          child: const ChangePasswordScreen(),
        ),
      ),
    );
  }
}

class _InfoItemWidget extends StatelessWidget {
  final InfoItem item;

  const _InfoItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 20,
            color:  Color.fromRGBO(92, 164, 104, 1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:  Color.fromRGBO(92, 164, 104, 1),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
