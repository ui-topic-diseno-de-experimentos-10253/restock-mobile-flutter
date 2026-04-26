import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_bloc.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_event.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_state.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    final state = context.read<InitialConfigBloc>().state;
    _firstNameController = TextEditingController(text: state.firstName);
    _lastNameController = TextEditingController(text: state.lastName);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController(text: state.phone);
    _addressController = TextEditingController(text: state.address);
    _countryController = TextEditingController(text: state.country);
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

  void _updateState() {
    context.read<InitialConfigBloc>().add(
          PersonalInfoChanged(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            country: _countryController.text,
          ),
        );
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
                  Icons.person_outline,
                  size: 64,
                  color: Color(0xFF1B5E20),
                ),
                const SizedBox(height: 16),
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s start with your basic information',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 32),

                // First Name
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Last Name
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Address
                _buildTextField(
                  controller: _addressController,
                  label: 'Address (Optional)',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 16),

                // Country
                _buildTextField(
                  controller: _countryController,
                  label: 'Country (Optional)',
                  icon: Icons.flag_outlined,
                  onChanged: (_) => _updateState(),
                ),
                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: state.isPersonalInfoValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<InitialConfigBloc>()
                                  .add(const NextToBusinessInfo());
                            }
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      'Next',
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
