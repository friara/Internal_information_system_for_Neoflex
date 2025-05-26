import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:openapi/openapi.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/role_emloyee/chat_page/personal_chat_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:dio/dio.dart';

class NotificationsPage extends StatefulWidget {
  final int currentUserId;

  const NotificationsPage({
    super.key,
    required this.currentUserId,
  });

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationControllerApi _notificationApi;
  late final UserControllerApi _userApi;
  late final ChatControllerApi _chatApi;

  List<MessageNotification> _notifications = [];
  final Map<int, UserDTO> _userCache = {};
  final Map<int, ChatDTO> _chatCache = {};
  bool _isLoading = true;
  int _unreadCount = 0;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  late String _avatarBaseUrl;
  late String _accessToken;

  @override
  void initState() {
    super.initState();
    final dio = GetIt.I<Dio>();
    _avatarBaseUrl = dio.options.baseUrl;
    if (!_avatarBaseUrl.endsWith('/')) {
      _avatarBaseUrl += '/';
    }
    GetIt.I<AuthRepositoryImpl>().getAccessToken().then((token) {
      if (mounted) {
        setState(() {
          _accessToken = token ?? '';
        });
      }
    });

    _notificationApi = GetIt.I<Openapi>().getNotificationControllerApi();
    _userApi = GetIt.I<Openapi>().getUserControllerApi();
    _chatApi = GetIt.I<Openapi>().getChatControllerApi();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final notificationsResponse = await _notificationApi.getNotifications();
      final notifications = notificationsResponse.data?.toList() ?? [];

      // Собираем уникальные ID пользователей и чатов
      final userIds =
          notifications.map((n) => n.sender).whereType<int>().toSet();
      final chatIds =
          notifications.map((n) => n.chatId).whereType<int>().toSet();

      // Параллельная загрузка дополнительных данных
      await Future.wait([
        _loadUsers(userIds),
        _loadChats(chatIds),
      ]);

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadCount = notifications.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Не удалось загрузить уведомления');
      }
    }
  }

  Future<void> _loadUsers(Set<int> userIds) async {
    for (final userId in userIds) {
      if (_userCache.containsKey(userId)) continue;

      try {
        final response = await _userApi.getUserById(id: userId);
        if (response.data != null) {
          _userCache[userId] = response.data!;
        }
      } catch (e) {
        debugPrint('Ошибка загрузки пользователя $userId: $e');
      }
    }
  }

  Future<void> _loadChats(Set<int> chatIds) async {
    for (final chatId in chatIds) {
      if (_chatCache.containsKey(chatId)) continue;

      try {
        final response = await _chatApi.getChatById(id: chatId);
        if (response.data != null) {
          _chatCache[chatId] = response.data!;
        }
      } catch (e) {
        debugPrint('Ошибка загрузки чата $chatId: $e');
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationApi.markAllAsRead();
      setState(() {
        _unreadCount = 0;
      });
    } catch (e) {
      _showError('Ошибка при обновлении статуса');
    }
  }

  void _navigateToChat(int? chatId) {
    if (chatId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonalChatPage(
            chatId: chatId,
            currentUserId: widget.currentUserId,
            onBack: () => _loadData(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        automaticallyImplyLeading: true,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Уведомления",
            style: TextStyle(
              fontFamily: 'Osmo Font',
              fontSize: 36.0,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_as_unread),
              onPressed: _markAllAsRead,
              tooltip: 'Пометить все как прочитанные',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _notifications.isEmpty
                  ? const Center(child: Text('Нет новых уведомлений'))
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _NotificationItem(
                          notification: notification,
                          user: _userCache[notification.sender],
                          chat: _chatCache[notification.chatId],
                          dateFormat: _dateFormat,
                          onTap: () => _navigateToChat(notification.chatId),
                          avatarBaseUrl: _avatarBaseUrl,
                          accessToken: _accessToken,
                        );
                      },
                    ),
            ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final MessageNotification notification;
  final UserDTO? user;
  final ChatDTO? chat;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  final String avatarBaseUrl;
  final String accessToken;

  const _NotificationItem({
    required this.notification,
    required this.user,
    required this.chat,
    required this.dateFormat,
    required this.onTap,
    required this.avatarBaseUrl,
    required this.accessToken,
  });

  String get _userName {
    if (user == null) return 'Неизвестный';
    return '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
  }

  String get _chatName {
    return chat?.chatName ?? 'Без названия';
  }

  String _getAvatarUrl() {
    if (user?.avatarUrl == null) return '';
    String avatarUrl = user!.avatarUrl!;
    if (avatarUrl.startsWith('http')) {
      return avatarUrl;
    } else {
      String base = avatarBaseUrl;
      if (!base.endsWith('/')) base += '/';
      if (avatarUrl.startsWith('/')) avatarUrl = avatarUrl.substring(1);
      return base + avatarUrl;
    }
  }

  Widget _buildAvatar() {
    final avatarUrl = _getAvatarUrl();
    return avatarUrl.isEmpty
        ? CircleAvatar(child: Text(_userName.isNotEmpty ? _userName[0] : '?'))
        : ClipOval(
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              httpHeaders: {'Authorization': 'Bearer $accessToken'},
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                color: Colors.grey,
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                color: Colors.grey,
                child: const Icon(Icons.error, size: 20),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      child: ListTile(
        leading: _buildAvatar(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _chatName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              _userName,
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.content ?? ''),
            if (notification.timestamp != null)
              Text(
                dateFormat.format(notification.timestamp!),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.circle, size: 12, color: Colors.purple),
        //: null,
        onTap: onTap,
      ),
    );
  }
}
