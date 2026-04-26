import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/profiles/data/remote/category_service.dart';
import 'package:restock/features/profiles/domain/models/business_category.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_event.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_state.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';

class BusinessInfoStep extends StatefulWidget {
  const BusinessInfoStep({super.key});

  @override
  State<BusinessInfoStep> createState() => _BusinessInfoStepState();
}

class _BusinessInfoStepState extends State<BusinessInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _businessAddressController;
  late TextEditingController _descriptionController;

  List<BusinessCategory> _categories = [];
  Set<String> _selectedCategoryIds = {};
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<InitialConfigBloc>().state;
    _businessNameController = TextEditingController(text: state.businessName);
    _businessAddressController = TextEditingController(text: state.businessAddress);
    _descriptionController = TextEditingController(text: state.description);
    _selectedCategoryIds = Set.from(state.categoryIds);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final token = await AuthStorage().getToken();
      if (token != null) {
        final categories = await CategoryService().getCategories(token);
        if (mounted) {
          setState(() {
            _categories = categories;
            _isLoadingCategories = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateState() {
    context.read<InitialConfigBloc>().add(
          BusinessInfoChanged(
            businessName: _businessNameController.text,
            businessAddress: _businessAddressController.text,
            description: _descriptionController.text,
            categoryIds: _selectedCategoryIds.toList(),
          ),
        );
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
    _updateState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitialConfigBloc, InitialConfigState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Color(0xFF1B5E20),
                ),
                const SizedBox(height: 16),
                Text(
                  'Business Information',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your business',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 32),

                // Business Name
                _buildTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  icon: Icons.store,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Business Address
                _buildTextField(
                  controller: _businessAddressController,
                  label: 'Business Address',
                  icon: Icons.location_city,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your business address';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 24),

                // Categories Section
                Text(
                  'Business Categories *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select at least one category',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 16),

                // Categories
                if (_isLoadingCategories)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_categories.isEmpty)
                  Card(
                    color: Colors.orange.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('No categories available'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategoryIds.contains(category.id);
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) => _toggleCategory(category.id),
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF1B5E20),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF1B5E20)
                              : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF1B5E20)
                                : Colors.grey.shade300,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                if (_selectedCategoryIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select at least one category',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<InitialConfigBloc>()
                                .add(const BackToPersonalInfo());
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(
                            'Back',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1B5E20),
                            side: const BorderSide(color: Color(0xFF1B5E20)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: state.isBusinessInfoValid
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    context
                                        .read<InitialConfigBloc>()
                                        .add(const SubmitConfiguration());
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text(
                            'Complete',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
