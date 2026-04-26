import 'package:restock/features/profiles/domain/models/business_category.dart';

abstract class EditBusinessDataEvent {
  const EditBusinessDataEvent();
}

class InitializeBusinessForm extends EditBusinessDataEvent {
  final String businessName;
  final String businessAddress;
  final String description;
  final List<BusinessCategory> selectedCategories;

  const InitializeBusinessForm({
    required this.businessName,
    required this.businessAddress,
    required this.description,
    required this.selectedCategories,
  });
}

class LoadAvailableCategories extends EditBusinessDataEvent {
  const LoadAvailableCategories();
}

class OnBusinessNameChanged extends EditBusinessDataEvent {
  final String businessName;
  const OnBusinessNameChanged({required this.businessName});
}

class OnBusinessAddressChanged extends EditBusinessDataEvent {
  final String businessAddress;
  const OnBusinessAddressChanged({required this.businessAddress});
}

class OnDescriptionChanged extends EditBusinessDataEvent {
  final String description;
  const OnDescriptionChanged({required this.description});
}

class AddCategory extends EditBusinessDataEvent {
  final BusinessCategory category;
  const AddCategory({required this.category});
}

class RemoveCategory extends EditBusinessDataEvent {
  final BusinessCategory category;
  const RemoveCategory({required this.category});
}

class SaveBusinessData extends EditBusinessDataEvent {
  const SaveBusinessData();
}
