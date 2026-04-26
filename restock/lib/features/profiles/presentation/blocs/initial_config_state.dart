import 'package:restock/core/enums/status.dart';

class InitialConfigState {
  final int currentStep;
  final Status status;
  final String? errorMessage;

  // Personal Info
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String country;

  // Business Info
  final String businessName;
  final String businessAddress;
  final String description;
  final List<String> categoryIds;

  // Subscription Info
  final bool subscriptionCompleted;

  const InitialConfigState({
    this.currentStep = 0,
    this.status = Status.initial,
    this.errorMessage,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.country = '',
    this.businessName = '',
    this.businessAddress = '',
    this.description = '',
    this.categoryIds = const [],
    this.subscriptionCompleted = false,
  });

  InitialConfigState copyWith({
    int? currentStep,
    Status? status,
    String? errorMessage,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? country,
    String? businessName,
    String? businessAddress,
    String? description,
    List<String>? categoryIds,
    bool? subscriptionCompleted,
  }) {
    return InitialConfigState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      country: country ?? this.country,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      description: description ?? this.description,
      categoryIds: categoryIds ?? this.categoryIds,
      subscriptionCompleted: subscriptionCompleted ?? this.subscriptionCompleted,
    );
  }

  bool get isPersonalInfoValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty;

  bool get isBusinessInfoValid =>
      businessName.isNotEmpty &&
      businessAddress.isNotEmpty;
}
