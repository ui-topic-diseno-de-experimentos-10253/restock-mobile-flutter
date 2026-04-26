import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/profiles/data/remote/business_update_service.dart';
import 'package:restock/features/profiles/data/remote/profile_update_service.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_event.dart';
import 'package:restock/features/profiles/presentation/blocs/initial_config_state.dart';

class InitialConfigBloc extends Bloc<InitialConfigEvent, InitialConfigState> {
  final ProfileUpdateService profileService;
  final BusinessUpdateService businessService;
  final AuthStorage storage;

  InitialConfigBloc({
    required this.profileService,
    required this.businessService,
    required this.storage,
  }) : super(const InitialConfigState()) {
    on<PersonalInfoChanged>(_onPersonalInfoChanged);
    on<NextToBusinessInfo>(_onNextToBusinessInfo);
    on<BusinessInfoChanged>(_onBusinessInfoChanged);
    on<BackToPersonalInfo>(_onBackToPersonalInfo);
    on<NextToSubscription>(_onNextToSubscription);
    on<BackToBusinessInfo>(_onBackToBusinessInfo);
    on<SubscriptionCompleted>(_onSubscriptionCompleted);
    on<SkipSubscription>(_onSkipSubscription);
    on<SubmitConfiguration>(_onSubmitConfiguration);
  }

  void _onPersonalInfoChanged(
    PersonalInfoChanged event,
    Emitter<InitialConfigState> emit,
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

  void _onNextToBusinessInfo(
    NextToBusinessInfo event,
    Emitter<InitialConfigState> emit,
  ) {
    if (state.isPersonalInfoValid) {
      emit(state.copyWith(currentStep: 1));
    }
  }

  void _onBusinessInfoChanged(
    BusinessInfoChanged event,
    Emitter<InitialConfigState> emit,
  ) {
    emit(state.copyWith(
      businessName: event.businessName,
      businessAddress: event.businessAddress,
      description: event.description,
      categoryIds: event.categoryIds,
    ));
  }

  void _onBackToPersonalInfo(
    BackToPersonalInfo event,
    Emitter<InitialConfigState> emit,
  ) {
    emit(state.copyWith(currentStep: 0));
  }

  void _onNextToSubscription(
    NextToSubscription event,
    Emitter<InitialConfigState> emit,
  ) async {
    if (!state.isPersonalInfoValid || !state.isBusinessInfoValid) {
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

      // Update personal information
      await profileService.updatePersonalInfo(
        token: token,
        userId: userId,
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email,
        phone: state.phone,
        address: state.address,
        country: state.country,
      );

      // Update business information
      await businessService.updateBusinessInfo(
        token: token,
        userId: userId,
        businessName: state.businessName,
        businessAddress: state.businessAddress,
        description: state.description,
        categoryIds: state.categoryIds,
      );

      emit(state.copyWith(status: Status.initial, currentStep: 2));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onBackToBusinessInfo(
    BackToBusinessInfo event,
    Emitter<InitialConfigState> emit,
  ) {
    emit(state.copyWith(currentStep: 1));
  }

  void _onSubscriptionCompleted(
    SubscriptionCompleted event,
    Emitter<InitialConfigState> emit,
  ) {
    emit(state.copyWith(
      subscriptionCompleted: true,
      status: Status.success,
    ));
  }

  void _onSkipSubscription(
    SkipSubscription event,
    Emitter<InitialConfigState> emit,
  ) {
    emit(state.copyWith(
      subscriptionCompleted: false,
      status: Status.success,
    ));
  }

  Future<void> _onSubmitConfiguration(
    SubmitConfiguration event,
    Emitter<InitialConfigState> emit,
  ) async {
    // This method is deprecated, use NextToSubscription instead
    add(const NextToSubscription());
  }
}
