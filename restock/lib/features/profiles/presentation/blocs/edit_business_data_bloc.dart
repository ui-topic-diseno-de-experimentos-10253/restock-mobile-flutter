import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/business_update_service.dart';
import 'package:restock/features/profiles/data/remote/category_service.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_event.dart';
import 'package:restock/features/profiles/presentation/blocs/edit_business_data_state.dart';

class EditBusinessDataBloc extends Bloc<EditBusinessDataEvent, EditBusinessDataState> {
  final BusinessUpdateService businessService;
  final CategoryService categoryService;
  final AuthStorage storage;

  EditBusinessDataBloc({
    required this.businessService,
    required this.categoryService,
    required this.storage,
  }) : super(const EditBusinessDataState()) {
    on<InitializeBusinessForm>(_onInitializeBusinessForm);
    on<LoadAvailableCategories>(_onLoadAvailableCategories);
    on<OnBusinessNameChanged>(_onBusinessNameChanged);
    on<OnBusinessAddressChanged>(_onBusinessAddressChanged);
    on<OnDescriptionChanged>(_onDescriptionChanged);
    on<AddCategory>(_onAddCategory);
    on<RemoveCategory>(_onRemoveCategory);
    on<SaveBusinessData>(_onSaveBusinessData);
  }

  FutureOr<void> _onInitializeBusinessForm(
    InitializeBusinessForm event,
    Emitter<EditBusinessDataState> emit,
  ) {
    emit(state.copyWith(
      businessName: event.businessName,
      businessAddress: event.businessAddress,
      description: event.description,
      selectedCategories: event.selectedCategories,
    ));
  }

  FutureOr<void> _onLoadAvailableCategories(
    LoadAvailableCategories event,
    Emitter<EditBusinessDataState> emit,
  ) async {
    emit(state.copyWith(categoriesStatus: Status.loading));
    try {
      final token = await storage.getToken();

      if (token == null) {
        emit(state.copyWith(
          categoriesStatus: Status.failure,
          categoriesError: 'User not authenticated',
        ));
        return;
      }

      final categories = await categoryService.getCategories(token);
      emit(state.copyWith(
        categoriesStatus: Status.success,
        availableCategories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        categoriesStatus: Status.failure,
        categoriesError: e.toString(),
      ));
    }
  }

  FutureOr<void> _onBusinessNameChanged(
    OnBusinessNameChanged event,
    Emitter<EditBusinessDataState> emit,
  ) {
    final error = _validateBusinessName(event.businessName);
    emit(state.copyWith(
      businessName: event.businessName,
      businessNameError: error,
      clearBusinessNameError: error == null,
    ));
  }

  FutureOr<void> _onBusinessAddressChanged(
    OnBusinessAddressChanged event,
    Emitter<EditBusinessDataState> emit,
  ) {
    final error = _validateBusinessAddress(event.businessAddress);
    emit(state.copyWith(
      businessAddress: event.businessAddress,
      businessAddressError: error,
      clearBusinessAddressError: error == null,
    ));
  }

  FutureOr<void> _onDescriptionChanged(
    OnDescriptionChanged event,
    Emitter<EditBusinessDataState> emit,
  ) {
    emit(state.copyWith(
      description: event.description,
      clearDescriptionError: true,
    ));
  }

  FutureOr<void> _onAddCategory(
    AddCategory event,
    Emitter<EditBusinessDataState> emit,
  ) {
    final updatedCategories = [...state.selectedCategories, event.category];
    emit(state.copyWith(
      selectedCategories: updatedCategories,
      clearCategoriesError: true,
    ));
  }

  FutureOr<void> _onRemoveCategory(
    RemoveCategory event,
    Emitter<EditBusinessDataState> emit,
  ) {
    final updatedCategories = state.selectedCategories
        .where((c) => c.id != event.category.id)
        .toList();
    emit(state.copyWith(selectedCategories: updatedCategories));
  }

  FutureOr<void> _onSaveBusinessData(
    SaveBusinessData event,
    Emitter<EditBusinessDataState> emit,
  ) async {
    // Validate all fields
    final businessNameError = _validateBusinessName(state.businessName);
    final businessAddressError = _validateBusinessAddress(state.businessAddress);
    final categoriesError = _validateCategories(state.selectedCategories);

    if (businessNameError != null ||
        businessAddressError != null ||
        categoriesError != null) {
      emit(state.copyWith(
        businessNameError: businessNameError,
        businessAddressError: businessAddressError,
        categoriesError: categoriesError,
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

      await businessService.updateBusinessData(
        token: token,
        userId: userId,
        businessName: state.businessName,
        businessAddress: state.businessAddress,
        description: state.description,
        categories: state.selectedCategories,
      );

      emit(state.copyWith(status: Status.success));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String? _validateBusinessName(String value) {
    if (value.trim().isEmpty) {
      return 'Business name is required';
    }
    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  String? _validateBusinessAddress(String value) {
    if (value.trim().isEmpty) {
      return 'Business address is required';
    }
    if (value.trim().length < 5) {
      return 'Business address must be at least 5 characters';
    }
    return null;
  }

  String? _validateCategories(List categories) {
    if (categories.isEmpty) {
      return 'At least one category is required';
    }
    return null;
  }
}
