import 'package:restock/core/enums/status.dart';
import 'package:restock/features/profiles/domain/models/business_category.dart';

class EditBusinessDataState {
  final Status status;
  final Status categoriesStatus;
  final String businessName;
  final String businessAddress;
  final String description;
  final List<BusinessCategory> selectedCategories;
  final List<BusinessCategory> availableCategories;
  final String? businessNameError;
  final String? businessAddressError;
  final String? descriptionError;
  final String? categoriesError;
  final String? errorMessage;

  const EditBusinessDataState({
    this.status = Status.initial,
    this.categoriesStatus = Status.initial,
    this.businessName = '',
    this.businessAddress = '',
    this.description = '',
    this.selectedCategories = const [],
    this.availableCategories = const [],
    this.businessNameError,
    this.businessAddressError,
    this.descriptionError,
    this.categoriesError,
    this.errorMessage,
  });

  bool get isValid =>
      businessName.isNotEmpty &&
      businessAddress.isNotEmpty &&
      selectedCategories.isNotEmpty &&
      businessNameError == null &&
      businessAddressError == null &&
      descriptionError == null &&
      categoriesError == null;

  List<BusinessCategory> get unselectedCategories {
    return availableCategories.where((available) {
      return !selectedCategories.any((selected) => selected.id == available.id);
    }).toList();
  }

  EditBusinessDataState copyWith({
    Status? status,
    Status? categoriesStatus,
    String? businessName,
    String? businessAddress,
    String? description,
    List<BusinessCategory>? selectedCategories,
    List<BusinessCategory>? availableCategories,
    String? businessNameError,
    String? businessAddressError,
    String? descriptionError,
    String? categoriesError,
    String? errorMessage,
    bool clearBusinessNameError = false,
    bool clearBusinessAddressError = false,
    bool clearDescriptionError = false,
    bool clearCategoriesError = false,
  }) {
    return EditBusinessDataState(
      status: status ?? this.status,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      description: description ?? this.description,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      availableCategories: availableCategories ?? this.availableCategories,
      businessNameError: clearBusinessNameError ? null : (businessNameError ?? this.businessNameError),
      businessAddressError: clearBusinessAddressError ? null : (businessAddressError ?? this.businessAddressError),
      descriptionError: clearDescriptionError ? null : (descriptionError ?? this.descriptionError),
      categoriesError: clearCategoriesError ? null : (categoriesError ?? this.categoriesError),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
