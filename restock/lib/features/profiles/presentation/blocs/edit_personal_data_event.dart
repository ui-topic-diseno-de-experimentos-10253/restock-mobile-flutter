abstract class EditPersonalDataEvent {
  const EditPersonalDataEvent();
}

class InitializeForm extends EditPersonalDataEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String country;

  const InitializeForm({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.country,
  });
}

class OnFirstNameChanged extends EditPersonalDataEvent {
  final String firstName;
  const OnFirstNameChanged({required this.firstName});
}

class OnLastNameChanged extends EditPersonalDataEvent {
  final String lastName;
  const OnLastNameChanged({required this.lastName});
}

class OnEmailChanged extends EditPersonalDataEvent {
  final String email;
  const OnEmailChanged({required this.email});
}

class OnPhoneChanged extends EditPersonalDataEvent {
  final String phone;
  const OnPhoneChanged({required this.phone});
}

class OnAddressChanged extends EditPersonalDataEvent {
  final String address;
  const OnAddressChanged({required this.address});
}

class OnCountryChanged extends EditPersonalDataEvent {
  final String country;
  const OnCountryChanged({required this.country});
}

class SavePersonalData extends EditPersonalDataEvent {
  const SavePersonalData();
}
