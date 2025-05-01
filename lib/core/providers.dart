// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_appauth/flutter_appauth.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:io' show Platform;
// import 'package:oauth2/oauth2.dart' as oauth2;
// import '../service/api_service.dart';
// import '../service/auth_service.dart';

// const authConfig = _AuthConfig(
//   baseUrl: 'http://localhost:9000',
//   clientId: 'your-client-id',
//   redirectUrl: 'myapp://oauth2redirect',
//   scopes: ['openid', 'profile'],
// );

// const apiConfig = _ApiConfig(
//   baseUrl: 'http://localhost:8080/api',
//   timeout: Duration(seconds: 5),
// );

// // Типизированные классы конфигурации
// class _AuthConfig {
//   final String baseUrl;
//   final String clientId;
//   final String redirectUrl;
//   final List<String> scopes;

//   const _AuthConfig({
//     required this.baseUrl,
//     required this.clientId,
//     required this.redirectUrl,
//     required this.scopes,
//   });
// }

// class _ApiConfig {
//   final String baseUrl;
//   final Duration timeout;

//   const _ApiConfig({
//     required this.baseUrl,
//     required this.timeout,
//   });
// }

// // Провайдеры для Dio
// final authDioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
//   baseUrl: authConfig.baseUrl,
//   connectTimeout: const Duration(seconds: 3),
// )));

// final apiDioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
//   baseUrl: apiConfig.baseUrl,
//   connectTimeout: const Duration(seconds: 5),
// )));

// // Secure Storage
// final secureStorageProvider = Provider<FlutterSecureStorage>(
//   (ref) => const FlutterSecureStorage(),
// );

// // AppAuth
// final appAuthProvider = Provider<FlutterAppAuth>(
//   (ref) => const FlutterAppAuth(),
// );

// final authServiceProvider = Provider<AuthService>((ref) {
//   return AuthService(
//     appAuth: !kIsWeb && (Platform.isAndroid || Platform.isIOS) 
//         ? const FlutterAppAuth() 
//         : null,
//     secureStorage: const FlutterSecureStorage(),
//     clientId: 'your-client-id',
//     redirectUrl: kIsWeb 
//         ? 'https://yourdomain.com/auth_callback'
//         : Platform.isAndroid || Platform.isIOS
//             ? 'com.yourapp://oauth2redirect'
//             : 'http://localhost:8080/callback',
//     issuer: 'https://your-auth-server.com',
//     scopes: ['openid', 'profile', 'email'],
//   );
// });

// final authClientProvider = FutureProvider<oauth2.Client?>((ref) async {
//   final authService = ref.read(authServiceProvider);
//   return await authService.loadSavedClient() ?? await authService.login();
// });

// // API Service
// final apiServiceProvider = Provider<ApiService>((ref) => ApiService(
//   dio: ref.read(apiDioProvider),
//   secureStorage: ref.read(secureStorageProvider),
//   authService: ref.read(authServiceProvider),
// ));