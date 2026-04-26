import 'package:restock/core/enums/status.dart';

class EditPersonalDataState {
  final Status status;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String country;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? phoneError;
  final String? addressError;
  final String? countryError;
  final String? errorMessage;

  const EditPersonalDataState({
    this.status = Status.initial,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.country = '',
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.phoneError,
    this.addressError,
    this.countryError,
    this.errorMessage,
  });

  bool get isValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      address.isNotEmpty &&
      country.isNotEmpty &&
      firstNameError == null &&
      lastNameError == null &&
      emailError == null &&
      phoneError == null &&
      addressError == null &&
      countryError == null;

  EditPersonalDataState copyWith({
    Status? status,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? country,
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? phoneError,
    String? addressError,
    String? countryError,
    String? errorMessage,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearAddressError = false,
    bool clearCountryError = false,
  }) {
    return EditPersonalDataState(
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      country: country ?? this.country,
      firstNameError: clearFirstNameError ? null : (firstNameError ?? this.firstNameError),
      lastNameError: clearLastNameError ? null : (lastNameError ?? this.lastNameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      addressError: clearAddressError ? null : (addressError ?? this.addressError),
      countryError: clearCountryError ? null : (countryError ?? this.countryError),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
