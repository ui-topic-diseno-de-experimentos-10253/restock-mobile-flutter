 
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/auth/data/remote/auth_service.dart';
import 'package:restock/features/auth/presentation/blocs/login_event.dart';
import 'package:restock/features/auth/presentation/blocs/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService service;
  final AuthStorage storage;

  LoginBloc({
    required this.service,
    required this.storage,
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
      // ahora login devuelve User
      final user = await service.login(state.email, state.password);

      // guardamos userId, token y username
      await storage.saveSession(
        userId: user.id,
        token: user.token,
        username: user.username,
      );

      emit(state.copyWith(
        status: Status.success,
        userSubscription: user.subscription,
      ));
    } catch (e) {
      emit(state.copyWith(status: Status.failure, message: e.toString()));
    }
  }
}
