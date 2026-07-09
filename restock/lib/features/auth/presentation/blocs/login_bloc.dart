 
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/core/services/fcm_manager.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/auth/data/remote/auth_service.dart';
import 'package:restock/features/auth/presentation/blocs/login_event.dart';
import 'package:restock/features/auth/presentation/blocs/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService service;
  final AuthStorage storage;
  final FcmManager fcmManager;

  LoginBloc({
    required this.service,
    required this.storage,
    required this.fcmManager,
  }) : super(const LoginState()) {
    on<OnEmailChanged>(
      (event, emit) => emit(state.copyWith(email: event.email)),
    );
    on<OnPasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.password)),
    );
    on<Login>(_onLogin);
  }

  FutureOr<void> _onLogin(Login event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: Status.loading));
    try {
      // Login returns a User with id, token and username.
      final user = await service.login(state.email, state.password);

      // Persist session.
      await storage.saveSession(
        userId: user.id,
        token: user.token,
        username: user.username,
      );

      // Register the FCM push token with the backend now that we have a userId.
      await fcmManager.syncToken(user.id);

      emit(state.copyWith(
        status: Status.success,
        userSubscription: user.subscription,
      ));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, message: e.toString()));
    }
  }
}
