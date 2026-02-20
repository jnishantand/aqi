import 'dart:async';

import 'package:bloc/bloc.dart';

class LoginState {
  final bool? isLoading;
  final String? error;
  final String? message;

  LoginState({this.isLoading, this.error, this.message});

  LoginState copyWith({
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }}

class AuthRepo {
  Future<String> getUserData() async {
    await Future.delayed(Duration(seconds: 2));
    return "Success";
  }
}

abstract class LoginEvents {}

class LoginButtonPressed implements LoginEvents {}

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  final AuthRepo authRepo;

  LoginBloc(this.authRepo) : super(LoginState()) {
    on<LoginButtonPressed>(_onLogin);
  }

  Future<void> _onLogin(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    try {
      emit(LoginState(isLoading: true));
      final user = await authRepo.getUserData();
      if (user.isNotEmpty) {
        emit(LoginState(isLoading: false, message: "nishant"));
      } else {
        emit(LoginState(isLoading: false, message: "failed"));
      }
    } catch (e) {
      emit(
        LoginState(isLoading: false, message: "failed", error: e.toString()),
      );
    }
  }
}
