import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_feed_neoflex/core/service_locator.dart';
import 'package:news_feed_neoflex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_feed_neoflex/features/notification/service/notification_service.dart';
import 'app_routes.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/features/notification/service/web_socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация зависимостей
  setupLocator();
  
  // Инициализация сервиса уведомлений
  await NotificationService().initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(getIt<AuthRepositoryImpl>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = getIt<WebSocketService>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          //_webSocketService.updateToken(state.token);
          _webSocketService.connect();
        } else if (state is AuthUnauthenticated) {
          _webSocketService.disconnect();
        }
      },
      child: MaterialApp(
        title: 'News Feed',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
        initialRoute: AppRoutes.loginPage,
        routes: AppRoutes.routes,
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}











// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:news_feed_neoflex/core/service_locator.dart';
// import 'package:news_feed_neoflex/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:news_feed_neoflex/features/notification/service/notification_service.dart';
// import 'package:news_feed_neoflex/features/notification/service/web_socket_service.dart';
// import 'package:get_it/get_it.dart';
// import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
// import 'app_routes.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Инициализация зависимостей
//   setupLocator();
  
//   // Инициализация сервиса уведомлений
//   await NotificationService().initialize();

//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => AuthBloc(getIt<AuthRepositoryImpl>())),
//         Provider(create: (_) => WebSocketService(baseUrl: 'ws://localhost:8080')),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthAuthenticated) {
//           final wsService = context.read<WebSocketService>();
//           wsService.updateToken(state.token);
          
//           wsService.stream.listen((message) {
//             NotificationService().showNotification('Новое уведомление', message);
//           });
//         }
//       },
//       child: MaterialApp(
//         title: 'News Feed',
//         theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
//         initialRoute: AppRoutes.loginPage,
//         routes: AppRoutes.routes,
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:news_feed_neoflex/app_routes.dart';
// import 'package:news_feed_neoflex/core/service_locator.dart';
// import 'package:news_feed_neoflex/features/auth/presentation/screens/login_screen.dart';
// import 'package:news_feed_neoflex/news_feed_page.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'features/auth/presentation/bloc/auth_bloc.dart';
// import 'features/auth/auth_repository_impl.dart';

// void main() async {
//   // Инициализация Flutter
//   WidgetsFlutterBinding.ensureInitialized();

//   // Инициализация sqflite для Windows
//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;

//   // Настройка локатора сервисов
//   setupLocator();

//   // Очищаем токены при каждом запуске (для тестирования)
//   final authRepo = AuthRepositoryImpl(storage: MobileSecureStorage());
//   await authRepo.logout(); // Удаляем все сохраненные токены
  

//   runApp(
//     MultiBlocProvider(
//       providers: <BlocProvider>[
//         BlocProvider<AuthBloc>(
//             create: (BuildContext context) =>
//                 AuthBloc(getIt<AuthRepositoryImpl>()))
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dynamic Image List',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//         useMaterial3: true,
//       ),
//       initialRoute: AppRoutes.loginPage,
//       routes: AppRoutes.routes,
//     );
//   }
// }
