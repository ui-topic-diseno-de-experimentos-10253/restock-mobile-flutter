import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restock/core/enums/status.dart';
import 'package:restock/features/auth/data/local/auth_storage.dart';
import 'package:restock/features/auth/data/remote/auth_service.dart';
import 'package:restock/features/auth/presentation/blocs/register_event.dart';
import 'package:restock/features/auth/presentation/blocs/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService service;
  final AuthStorage storage;

  RegisterBloc({
    required this.service,
    required this.storage,
  }) : super(const RegisterState()) {

    on<OnUsernameChanged>((event, emit) {
      emit(state.copyWith(
        username: event.username,
        status: Status.initial,
      ));
    });

    on<OnPasswordChangedRegister>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        status: Status.initial,
      ));
    });

    on<OnRoleChanged>((event, emit) {
      emit(state.copyWith(
        roleId: event.roleId,
        status: Status.initial,
      ));
    });

    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  FutureOr<void> _onRegisterSubmitted(
      RegisterSubmitted event,
      Emitter<RegisterState> emit
  ) async {
    emit(state.copyWith(status: Status.loading));

    try {
      // 1. Register the user

      await service.register(
        username: state.username,
        password: state.password,
        roleId: state.roleId,
      );

      // 2. Automatically login after successful registration
      final user = await service.login(state.username, state.password);

      // 3. Save the session (userId, token and username)
      await storage.saveSession(
        userId: user.id,
        token: user.token,
        username: user.username,
      );

      // Hacer login automático después del registro
      //final user = await service.login(state.username, state.password);

      // Guardar sesión
      await storage.saveSession(
        userId: user.id,
        token: user.token,
      );

      emit(state.copyWith(
        status: Status.success,
        userSubscription: user.subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        message: e.toString(),
      ));
    }
  }
}
