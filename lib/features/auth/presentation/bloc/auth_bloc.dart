import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth_repository_impl.dart';

part './auth_event.dart';
part './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;
  String? _currentToken;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final client = await _authRepository.login();
      _currentToken = await _authRepository.getAccessToken();
      emit(AuthAuthenticated(_currentToken!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    _currentToken = null;
    emit(AuthUnauthenticated());
  }
}









// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../auth_repository_impl.dart';

// part './auth_event.dart';
// part './auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepositoryImpl _authRepository;

//   AuthBloc(this._authRepository) : super(AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<LogoutRequested>(_onLogoutRequested);
//   }

//   Future<void> _onLoginRequested(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       await _authRepository.login();
//       emit(AuthAuthenticated());
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     await _authRepository.logout();
//     emit(AuthUnauthenticated());
//   }
// }