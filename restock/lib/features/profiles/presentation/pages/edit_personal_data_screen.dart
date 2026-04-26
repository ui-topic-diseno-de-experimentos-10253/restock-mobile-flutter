import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/domain/models/profile.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_event.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_state.dart';

class EditPersonalDataScreen extends StatefulWidget {
  final Profile profile;

  const EditPersonalDataScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditPersonalDataScreen> createState() => _EditPersonalDataScreenState();
}

class _EditPersonalDataScreenState extends State<EditPersonalDataScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.profile.firstName;
    _lastNameController.text = widget.profile.lastName;
    _emailController.text = widget.profile.email;
    _phoneController.text = widget.profile.phone;
    _addressController.text = widget.profile.address;
    _countryController.text = widget.profile.country;

    context.read<EditPersonalDataBloc>().add(
          InitializeForm(
            firstName: widget.profile.firstName,
            lastName: widget.profile.lastName,
            email: widget.profile.email,
            phone: widget.profile.phone,
            address: widget.profile.address,
            country: widget.profile.country,
          ),
        );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
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
        title: const Text('Edit your information'),
      ),
      body: BlocConsumer<EditPersonalDataBloc, EditPersonalDataState>(
        listener: (context, state) {
          if (state.status == Status.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Personal data updated successfully'),
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
                Text(
                  'Personal data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // First Name
                TextField(
                  controller: _firstNameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.firstNameError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnFirstNameChanged(firstName: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Last Name
                TextField(
                  controller: _lastNameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.lastNameError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnLastNameChanged(lastName: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: _emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.emailError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnEmailChanged(email: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: _phoneController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.phoneError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnPhoneChanged(phone: value),
                        );
                  },
                ),
                const SizedBox(height: 24),

                // Address
                TextField(
                  controller: _addressController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.addressError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnAddressChanged(address: value),
                        );
                  },
                ),
                const SizedBox(height: 16),

                // Country
                TextField(
                  controller: _countryController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: state.countryError,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    context.read<EditPersonalDataBloc>().add(
                          OnCountryChanged(country: value),
                        );
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<EditPersonalDataBloc>().add(
                                  const SavePersonalData(),
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
