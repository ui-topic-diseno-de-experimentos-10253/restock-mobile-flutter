import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/profile_update_service.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_event.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_personal_data_state.dart';

class EditPersonalDataBloc extends Bloc<EditPersonalDataEvent, EditPersonalDataState> {
  final ProfileUpdateService service;
  final AuthStorage storage;

  EditPersonalDataBloc({
    required this.service,
    required this.storage,
  }) : super(const EditPersonalDataState()) {
    on<InitializeForm>(_onInitializeForm);
    on<OnFirstNameChanged>(_onFirstNameChanged);
    on<OnLastNameChanged>(_onLastNameChanged);
    on<OnEmailChanged>(_onEmailChanged);
    on<OnPhoneChanged>(_onPhoneChanged);
    on<OnAddressChanged>(_onAddressChanged);
    on<OnCountryChanged>(_onCountryChanged);
    on<SavePersonalData>(_onSavePersonalData);
  }

  FutureOr<void> _onInitializeForm(
    InitializeForm event,
    Emitter<EditPersonalDataState> emit,
  ) {
    emit(state.copyWith(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      address: event.address,
      country: event.country,
    ));
  }

  FutureOr<void> _onFirstNameChanged(
    OnFirstNameChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validateFirstName(event.firstName);
    emit(state.copyWith(
      firstName: event.firstName,
      firstNameError: error,
      clearFirstNameError: error == null,
    ));
  }

  FutureOr<void> _onLastNameChanged(
    OnLastNameChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validateLastName(event.lastName);
    emit(state.copyWith(
      lastName: event.lastName,
      lastNameError: error,
      clearLastNameError: error == null,
    ));
  }

  FutureOr<void> _onEmailChanged(
    OnEmailChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validateEmail(event.email);
    emit(state.copyWith(
      email: event.email,
      emailError: error,
      clearEmailError: error == null,
    ));
  }

  FutureOr<void> _onPhoneChanged(
    OnPhoneChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validatePhone(event.phone);
    emit(state.copyWith(
      phone: event.phone,
      phoneError: error,
      clearPhoneError: error == null,
    ));
  }

  FutureOr<void> _onAddressChanged(
    OnAddressChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validateAddress(event.address);
    emit(state.copyWith(
      address: event.address,
      addressError: error,
      clearAddressError: error == null,
    ));
  }

  FutureOr<void> _onCountryChanged(
    OnCountryChanged event,
    Emitter<EditPersonalDataState> emit,
  ) {
    final error = _validateCountry(event.country);
    emit(state.copyWith(
      country: event.country,
      countryError: error,
      clearCountryError: error == null,
    ));
  }

  FutureOr<void> _onSavePersonalData(
    SavePersonalData event,
    Emitter<EditPersonalDataState> emit,
  ) async {
    // Validate all fields
    final firstNameError = _validateFirstName(state.firstName);
    final lastNameError = _validateLastName(state.lastName);
    final emailError = _validateEmail(state.email);
    final phoneError = _validatePhone(state.phone);
    final addressError = _validateAddress(state.address);
    final countryError = _validateCountry(state.country);

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        phoneError != null ||
        addressError != null ||
        countryError != null) {
      emit(state.copyWith(
        firstNameError: firstNameError,
        lastNameError: lastNameError,
        emailError: emailError,
        phoneError: phoneError,
        addressError: addressError,
        countryError: countryError,
      ));
      return;
    }

    emit(state.copyWith(status: Status.loading));
    try {
      final token = await storage.getToken();
      final userId = await storage.getUserId();

      if (token == null || userId == null) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: 'User not authenticated',
        ));
        return;
      }

      await service.updatePersonalData(
        token: token,
        userId: userId,
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email,
        phone: state.phone,
        address: state.address,
        country: state.country,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String? _validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  String? _validateLastName(String value) {
    if (value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePhone(String value) {
    if (value.trim().isEmpty) {
      return 'Phone is required';
    }
    if (value.trim().length < 8) {
      return 'Phone must be at least 8 characters';
    }
    return null;
  }

  String? _validateAddress(String value) {
    if (value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  String? _validateCountry(String value) {
    if (value.trim().isEmpty) {
      return 'Country is required';
    }
    if (value.trim().length < 2) {
      return 'Country must be at least 2 characters';
    }
    return null;
  }
}
