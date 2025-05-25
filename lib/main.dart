import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_feed_neoflex/core/service_locator.dart';
import 'package:news_feed_neoflex/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_feed_neoflex/features/notification/service/notification_service.dart';
import 'app_routes.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/features/notification/service/web_socket_service.dart';

// Добавляем глобальный ключ для навигации
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        debugShowCheckedModeBanner: false,
        title: 'News Feed',
        // Добавляем navigatorKey для глобальной навигации
        navigatorKey: navigatorKey,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
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
