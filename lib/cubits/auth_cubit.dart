import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> restoreSession() async {
    final user = await AuthService.getUser();

    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      clearMessage: true,
    ));

    final result = await ApiService.post({
      'action': 'login',
      'username': username,
      'password': password,
    });

    if (result['success'] == true) {
      final user = User.fromJson(result['data']);
      await AuthService.saveUser(user);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } else {
      emit(AuthState(
        status: AuthStatus.failure,
        message: result['message']?.toString() ?? 'Login failed.',
      ));
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
