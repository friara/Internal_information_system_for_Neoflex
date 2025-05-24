import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openapi/openapi.dart';
import '../data/message_notification_dto.dart';
import 'dart:convert';


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
    );
  }

  Future<void> showMessageNotification(MessageNotificationDTO message) async {
    final platformDetails = _buildPlatformDetails();
    
    await _notificationsPlugin.show(
      message.id.hashCode,
      'Новое сообщение в чате',
      _buildNotificationContent(message),
      NotificationDetails(
        windows: platformDetails,
        // Добавьте настройки для других платформ
      ),
      payload: jsonEncode(message.toJson()),
    );
  }
  
 WindowsNotificationDetails _buildPlatformDetails() {
    return const WindowsNotificationDetails(
      //toastActivatorClsid: '173cca6c-fc60-444e-8be1-cb9656aa3fed',
      // Дополнительные параметры для Windows уведомлений:
      // channelName: 'Новости',
      //icon: 'assets/notification_icon.png',
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