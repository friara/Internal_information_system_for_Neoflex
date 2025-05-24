import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:openapi/openapi.dart';
import '../data/message_notification_dto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:news_feed_neoflex/main.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/role_emloyee/chat_page/personal_chat_page.dart';
import 'package:flutter/material.dart';



class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const WindowsInitializationSettings windowsSettings = 
        WindowsInitializationSettings(
          appName: 'NeoflexApp',
          appUserModelId: 'Neoflex.NewsFeed.1.0.0',
          guid: '173cca6c-fc60-444e-8be1-cb9656aa3fed',
        );

    await _notificationsPlugin.initialize(
      const InitializationSettings(windows: windowsSettings),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleNotificationClick(details.payload!);
        }
      },
    );
  }

void _handleNotificationClick(String payload) {
  // try {
  //   // Добавьте проверку UTF-8
  //   final utf8Payload = utf8.decode(
  //     payload.runes.toList(), // Конвертация Runes в List<int>
  //     allowMalformed: false, // Запретить невалидные символы
  //   );
    
  //   final jsonData = jsonDecode(utf8Payload) as Map<String, dynamic>;
  //   final message = MessageNotificationDTO.fromJson(jsonData);
    
  //   navigatorKey.currentState?.push(
  //       MaterialPageRoute(
  //         builder: (context) => PersonalChatPage(
  //           chatId: message.chatId,
  //           currentUserId: GetIt.I<AuthRepositoryImpl>().getCurrentUserId(),
  //         ),
  //       ),
  //     );
  // } on FormatException catch (e) {
  //   debugPrint('Некорректный payload: ${e.message}\nИсходные данные: $payload');
  // } catch (e) {
  //   debugPrint('Ошибка: $e');
  // }
}

  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime.toLocal()); // Формат "ЧЧ:ММ"
  }

  Future<void> showMessageNotification(MessageNotificationDTO message) async {
    final platformDetails = _buildPlatformDetails();

    final payload = jsonEncode(message.toJson());
  
  // Логирование байтов payload
  debugPrint('Payload bytes: ${payload.codeUnits}');
  debugPrint('Payload string: $payload');
    
    String contentText = message.content.isNotEmpty 
        ? message.content 
        : 'Новое сообщение';
    String formattedTime = _formatTime(message.timestamp);
    
    await _notificationsPlugin.show(
      _generateNotificationId(message),
      message.chatName,
      '${message.sender}: $contentText\n$formattedTime',
      NotificationDetails(
        windows: platformDetails,
      ),
      payload: payload,
    );
  }
  
// Используйте уникальный идентификатор (например, timestamp + id)
int _generateNotificationId(MessageNotificationDTO message) {
  return message.timestamp.millisecondsSinceEpoch + message.id.hashCode;
}

 WindowsNotificationDetails _buildPlatformDetails() {
    return WindowsNotificationDetails(
      audio: WindowsNotificationAudio.preset(sound: WindowsNotificationSound.alarm2)
    );
  }

  String _buildNotificationContent(MessageNotificationDTO message) {
    if (message.content.isNotEmpty) return message.content;
    // if (message.linkedMessage.files.isNotEmpty) {
    //   return '📎 Вложение: ${message.linkedMessage.files.first.fileName}';
    // }
    return 'Новое сообщение';
  }
}