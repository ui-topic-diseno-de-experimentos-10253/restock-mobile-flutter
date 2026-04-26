abstract class InitialConfigEvent {
  const InitialConfigEvent();
}

// Personal Info Events
class PersonalInfoChanged extends InitialConfigEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? country;

  const PersonalInfoChanged({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.country,
  });
}

class NextToBusinessInfo extends InitialConfigEvent {
  const NextToBusinessInfo();
}

// Business Info Events
class BusinessInfoChanged extends InitialConfigEvent {
  final String? businessName;
  final String? businessAddress;
  final String? description;
  final List<String>? categoryIds;

  const BusinessInfoChanged({
    this.businessName,
    this.businessAddress,
    this.description,
    this.categoryIds,
  });
}

class BackToPersonalInfo extends InitialConfigEvent {
  const BackToPersonalInfo();
}

class NextToSubscription extends InitialConfigEvent {
  const NextToSubscription();
}

class BackToBusinessInfo extends InitialConfigEvent {
  const BackToBusinessInfo();
}

class SubscriptionCompleted extends InitialConfigEvent {
  const SubscriptionCompleted();
}

class SkipSubscription extends InitialConfigEvent {
  const SkipSubscription();
}

class SubmitConfiguration extends InitialConfigEvent {
  const SubmitConfiguration();
}
