part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Добавляем параметр token
class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token); // Принимаем токен в конструкторе
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}