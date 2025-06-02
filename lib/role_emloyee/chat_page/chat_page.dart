import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/constans/app_style.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'package:openapi/openapi.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'personal_chat_page.dart';
import 'contact_selection_page.dart';
import 'group_creation_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool _showCreateOptions = false;

  List<ChatSummaryDTO> _chats = [];
  List<UserDTO> _allUsers = [];
  bool _isLoading = true;
  int? _currentUserId;
  int _selectedIndex = 2;

  late String _avatarBaseUrl;
  late String accessToken;
  bool _isAdmin = false;
  bool _isRoleLoaded = false;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    final dio = GetIt.I<Dio>();
    _avatarBaseUrl = dio.options.baseUrl;
    if (!_avatarBaseUrl.endsWith('/')) {
      _avatarBaseUrl += '/';
    }
    GetIt.I<AuthRepositoryImpl>().getAccessToken().then((token) {
      if (token != null) {
        setState(() {
          accessToken = token;
        });
      }
    });
    _loadData();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userApi = GetIt.I<Openapi>().getUserControllerApi();
      final response = await userApi.getCurrentUser();

      if (response.data == null || response.data!.roleName == null) {
        throw Exception('User data or role is null');
      }

      setState(() {
        _currentUserRole = response.data!.roleName!.toUpperCase().trim();
        _isAdmin = _currentUserRole == 'ROLE_ADMIN';
        _isRoleLoaded = true;
      });
    } catch (e) {
      debugPrint('Error loading user role: $e');
      setState(() => _isRoleLoaded = true);
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final currentUserResponse =
          await GetIt.I<Openapi>().getUserControllerApi().getCurrentUser();
      _currentUserId = currentUserResponse.data?.id;

      if (_currentUserId == null) {
        throw Exception('Не удалось получить ID текущего пользователя');
      }

      final chatsResponse =
          await GetIt.I<Openapi>().getChatControllerApi().getMyChats();
      final usersResponse =
          await GetIt.I<Openapi>().getUserControllerApi().getAllUsers();

      setState(() {
        _chats = chatsResponse.data?.content?.toList() ?? [];
        _allUsers = usersResponse.data?.toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки чатов: ${e.toString()}')),
      );
      debugPrint('Ошибка в _loadData: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() => _isSearchActive = query.isNotEmpty);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearchActive = false;
    });
  }

  List<UserDTO> _getFilteredUsers() {
    if (_currentUserId == null) return _allUsers;
    return _allUsers.where((user) => user.id != _currentUserId).toList();
  }

  Future<void> _createContactChat(int otherUserId) async {
    try {
      final chatApi = GetIt.I<Openapi>().getChatControllerApi();
      final currentUserResponse =
          await GetIt.I<Openapi>().getUserControllerApi().getCurrentUser();
      final currentUserId = currentUserResponse.data?.id;

      if (currentUserId == null) {
        throw Exception('Не удалось получить ID текущего пользователя');
      }

      final chatDTO = ChatDTO(
        (b) => b
          ..chatType = 'PRIVATE'
          ..otherUserId = otherUserId
          ..createdBy = currentUserId
          ..participantIds = ListBuilder<int>([otherUserId]),
      );

      final response = await chatApi.createChat(chatDTO: chatDTO);

      if (response.data != null) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Чат успешно создан')),
        );
      }
    } catch (e) {
      debugPrint('Error creating chat: $e');
      if (e is DioException) {
        debugPrint('Response data: ${e.response?.data}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания чата: ${e.toString()}')),
      );
    }
  }

  Future<void> _createGroup(
    String groupName,
    List<int> participantIds,
  ) async {
    try {
      final chatApi = GetIt.I<Openapi>().getChatControllerApi();
      final currentUserResponse =
          await GetIt.I<Openapi>().getUserControllerApi().getCurrentUser();
      final currentUserId = currentUserResponse.data?.id;

      if (currentUserId == null) {
        throw Exception('Не удалось получить ID текущего пользователя');
      }

      final chatDTO = ChatDTO(
        (b) => b
          ..chatType = 'GROUP'
          ..chatName = groupName
          ..createdBy = currentUserId
          ..participantIds = ListBuilder<int>(participantIds),
      );

      final response = await chatApi.createChat(chatDTO: chatDTO);

      if (response.data != null) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Группа успешно создана')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания группы: ${e.toString()}')),
      );
    }
  }

  Widget _buildCreateOptionsOverlay() {
    return Positioned(
      top: 70,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Создать группу'),
                onTap: () async {
                  setState(() => _showCreateOptions = false);
                  final filteredUsers = _getFilteredUsers();

                  if (filteredUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Нет доступных пользователей для добавления')),
                    );
                    return;
                  }

                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreationPage(
                        users: filteredUsers,
                        avatarBaseUrl: _avatarBaseUrl,
                        accessToken: accessToken,
                      ),
                    ),
                  );

                  if (result != null &&
                      result['groupName'] != null &&
                      result['participantIds'] != null) {
                    await _createGroup(
                      result['groupName'] as String,
                      result['participantIds'] as List<int>,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Создать контакт'),
                onTap: () async {
                  setState(() => _showCreateOptions = false);
                  final filteredUsers = _getFilteredUsers();

                  if (filteredUsers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Нет доступных пользователей для добавления')),
                    );
                    return;
                  }

                  final selectedUserId = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactSelectionPage(
                        users: filteredUsers,
                        avatarBaseUrl: _avatarBaseUrl,
                        accessToken: accessToken,
                      ),
                    ),
                  );

                  if (selectedUserId != null) {
                    await _createContactChat(selectedUserId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.newsFeed,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.bookPage,
          (route) => false,
        );
        break;
      case 2:
        break;
      case 3:
        if (_isAdmin) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.listOfUsers,
            (route) => false,
          );
        } else {
          try {
            final userApi = GetIt.I<Openapi>().getUserControllerApi();
            final response = await userApi.getCurrentUser();
            if (response.data != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                    userData: {
                      'id': response.data!.id?.toString() ?? '',
                      'fio':
                          '${response.data!.firstName ?? ''} ${response.data!.lastName ?? ''} ${response.data!.patronymic ?? ''}',
                      'phone': response.data!.phoneNumber ?? '',
                      'position': response.data!.appointment ?? '',
                      'role': response.data!.roleName ?? 'ROLE_USER',
                      'login': response.data!.login ?? '',
                      'birthDate': response.data!.birthday?.toString() ?? '',
                      'avatarUrl': response.data!.avatarUrl ?? '',
                    },
                    onSave: (updatedUser) async {
                      try {
                        await GetIt.I<Openapi>()
                            .getUserControllerApi()
                            .updateCurrentUser(userDTO: updatedUser);

                        final updatedResponse = await userApi.getCurrentUser();
                        if (updatedResponse.data != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Профиль успешно обновлен')),
                          );
                        }
                      } catch (e) {
                        debugPrint('API Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Ошибка сохранения: ${e.toString()}')),
                        );
                        rethrow;
                      }
                    },
                    onDelete: (userId) {
                      // Логика удаления
                    },
                    onAvatarChanged: (file) {
                      // Логика обновления аватара
                    },
                    isAdmin: false,
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Ошибка загрузки профиля: ${e.toString()}')),
            );
          }
        }
        break;
    }
  }

  Future<ChatDTO?> _getFullChatInfo(int chatId) async {
    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) return null;

      final response =
          await GetIt.I<Openapi>().getChatControllerApi().getChatById(
        id: chatId,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.data;
    } catch (e) {
      debugPrint('Error getting full chat info: $e');
      return null;
    }
  }

  void _handleLongPressChat(ChatSummaryDTO chatSummary) async {
    final fullChat = await _getFullChatInfo(chatSummary.id!);
    if (fullChat == null) return;

    final isGroup = fullChat.chatType == 'GROUP';
    final isOwner = fullChat.createdBy == _currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isGroup && isOwner)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Удалить чат',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteChatForEveryone(fullChat.id!);
                  },
                ),
              if (isGroup && !isOwner)
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Выйти и удалить чат',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _exitFromGroupChat(fullChat.id!);
                  },
                ),
              if (!isGroup)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Удалить чат',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteChatForEveryone(fullChat.id!);
                  },
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Отмена'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteChatForEveryone(int chatId) async {
    final title = 'Удалить чат?';
    final content =
        'Чат будет полностью удален для всех участников. Это действие нельзя отменить.';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
        if (token == null) return;

        await GetIt.I<Openapi>().getChatControllerApi().deleteChat(
          id: chatId,
          headers: {'Authorization': 'Bearer $token'},
        );

        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Чат успешно удален')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления чата: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _exitFromGroupChat(int chatId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из чата?'),
        content:
            const Text('Вы больше не будете получать сообщения из этого чата.'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
        if (token == null) return;

        await GetIt.I<Openapi>().getChatControllerApi().exitFromChat(
          chatId: chatId,
          headers: {'Authorization': 'Bearer $token'},
        );

        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы вышли из чата')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка выхода из чата: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final query = _searchController.text.toLowerCase();

    final filteredChats = _isSearchActive
        ? _chats
            .where(
                (chat) => chat.chatName?.toLowerCase().contains(query) ?? false)
            .toList()
        : _chats;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Column(
          children: [
            AppBar(
              foregroundColor: Colors.purple,
              automaticallyImplyLeading: false,
              title: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Чаты",
                  style: AppStyles.heading2,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _showCreateOptions = true),
                ),
              ],
              surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 104, 102, 102),
                    ),
                    hintText: 'Поиск',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.purple, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_isSearchActive ? Icons.close : Icons.search),
                      onPressed:
                          _isSearchActive ? _clearSearch : _performSearch,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) => GestureDetector(
                              onLongPress: () =>
                                  _handleLongPressChat(filteredChats[index]),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppStyles.pink,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        style: AppStyles.textMain,
                                        filteredChats[index].chatName ?? 'Чат'),
                                    subtitle: Text(filteredChats[index]
                                            .lastMessagePreview ??
                                        ''),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PersonalChatPage(
                                          chatId: filteredChats[index].id!,
                                          currentUserId: _currentUserId!,
                                          onBack: () => _loadData(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )),
              ),
            ],
          ),
          if (_showCreateOptions) _buildCreateOptionsOverlay(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppStyles.purple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
