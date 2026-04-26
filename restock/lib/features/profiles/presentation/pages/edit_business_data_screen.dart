import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/domain/models/profile.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_event.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_state.dart';

class EditBusinessDataScreen extends StatefulWidget {
  final Profile profile;

  const EditBusinessDataScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditBusinessDataScreen> createState() => _EditBusinessDataScreenState();
}

class _EditBusinessDataScreenState extends State<EditBusinessDataScreen> {
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _businessNameController.text = widget.profile.businessName;
    _businessAddressController.text = widget.profile.businessAddress;
    _descriptionController.text = widget.profile.description ?? '';

    final bloc = context.read<EditBusinessDataBloc>();
    bloc.add(
      InitializeBusinessForm(
        businessName: widget.profile.businessName,
        businessAddress: widget.profile.businessAddress,
        description: widget.profile.description ?? '',
        selectedCategories: widget.profile.categories,
      ),
    );
    bloc.add(const LoadAvailableCategories());
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _descriptionController.dispose();
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
        title: const Text('Business Data'),
      ),
      body: BlocConsumer<EditBusinessDataBloc, EditBusinessDataState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Business data updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
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
                // Company Name
                TextField(
                  controller: _businessNameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.businessNameError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditBusinessDataBloc>().add(
                          OnBusinessNameChanged(businessName: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Company Address
                TextField(
                  controller: _businessAddressController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Company Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.businessAddressError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditBusinessDataBloc>().add(
                          OnBusinessAddressChanged(businessAddress: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: _descriptionController,
                  enabled: !isLoading,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.descriptionError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditBusinessDataBloc>().add(
                          OnDescriptionChanged(description: value),
                        );
                  },
                ),
                const SizedBox(height: 24),

                // Company Category Section
                Text(
                  'Company category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Categories Content
                if (state.categoriesStatus == Status.loading)
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.categoriesStatus == Status.failure)
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.categoriesError ?? 'Failed to load categories',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            context.read<EditBusinessDataBloc>().add(
                                  const LoadAvailableCategories(),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Categories
                      if (state.selectedCategories.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.selectedCategories
                              .map(
                                (category) => InputChip(
                                  label: Text(category.name),
                                  avatar: Icon(
                                    Icons.category,
                                    size: 18,
                                  ),
                                  selected: true,
                                  onDeleted: isLoading
                                      ? null
                                      : () {
                                          context.read<EditBusinessDataBloc>().add(
                                                RemoveCategory(category: category),
                                              );
                                        },
                                  deleteIcon: Icon(Icons.close, size: 18),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Available Categories
                      if (state.unselectedCategories.isNotEmpty) ...[
                        Text(
                          'Available categories',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color:  Color.fromRGBO(92, 164, 104, 1),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.unselectedCategories
                              .map(
                                (category) => ActionChip(
                                  label: Text(category.name),
                                  avatar: Icon(
                                    Icons.add_circle_outline,
                                    size: 18,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.read<EditBusinessDataBloc>().add(
                                                AddCategory(category: category),
                                              );
                                        },
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      // Categories Error
                      if (state.categoriesError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.categoriesError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<EditBusinessDataBloc>().add(
                                  const SaveBusinessData(),
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
