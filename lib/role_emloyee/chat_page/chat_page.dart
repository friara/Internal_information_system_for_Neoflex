import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'package:openapi/openapi.dart';
import 'dart:io';
import 'personal_chat_page.dart';
import 'contact_selection_page.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool _showCreateOptions = false;
  bool _showGroupCreation = false;
  Map<int, bool> _selectedUsers = {};
  File? _groupImage;
  final TextEditingController _groupNameController = TextEditingController();

  List<ChatSummaryDTO> _chats = [];
  List<UserDTO> _allUsers = [];
  bool _isLoading = true;
  int? _currentUserId;
  int _selectedIndex = 2; // Индекс для выделения текущего экрана в навигации

  late String _avatarBaseUrl;
  late String accessToken;
  bool _isAdmin = false;
  bool _isRoleLoaded = false;
  String? _currentUserRole;

late String _avatarBaseUrl;
  late String accessToken;

late String _avatarBaseUrl;
  late String accessToken;

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

      // Получаем текущего пользователя
      final currentUserResponse =
          await GetIt.I<Openapi>().getUserControllerApi().getCurrentUser();
      _currentUserId = currentUserResponse.data?.id;

      if (_currentUserId == null) {
        throw Exception('Не удалось получить ID текущего пользователя');
      }

      // Загружаем чаты текущего пользователя
      final chatsResponse =
          await GetIt.I<Openapi>().getChatControllerApi().getMyChats();

      // Загружаем всех пользователей (для создания групп)
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
    _groupNameController.dispose();
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

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _groupImage = File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при выборе изображения')),
      );
    }
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty ||
        !_selectedUsers.values.any((v) => v)) return;

    try {
      final chatApi = GetIt.I<Openapi>().getChatControllerApi();

      final participantIds = _selectedUsers.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final chatDTO = ChatDTO(
        (b) => b
          ..chatType = 'GROUP'
          ..chatName = _groupNameController.text
          ..participantIds = ListBuilder<int>(participantIds),
      );

      final response = await chatApi.createChat(chatDTO: chatDTO);

      if (response.data != null) {
        setState(() {
          _showGroupCreation = false;
          _groupNameController.clear();
          _selectedUsers = {};
          _groupImage = null;
          _chats.insert(0, _convertToSummary(response.data!));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания группы: ${e.toString()}')),
      );
    }
  }

  ChatSummaryDTO _convertToSummary(ChatDTO chat) {
    return ChatSummaryDTO(
      (b) => b
        ..id = chat.id
        ..chatType = chat.chatType
        ..chatName = chat.chatName
        ..lastActivity = chat.createdWhen
        ..lastMessagePreview = 'Новый чат создан',
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
        // Уже на этом экране
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
              title: Align(
                alignment: Alignment.centerLeft,
                child: _showGroupCreation
                    ? const Text("Создание группы")
                    : const Text("Чаты"),
              ),
              actions: _showGroupCreation
                  ? null
                  : [
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              setState(() => _showCreateOptions = true)),
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
                        itemBuilder: (context, index) => ListTile(
                          title: Text(filteredChats[index].chatName ?? 'Чат'),
                          subtitle: Text(
                              filteredChats[index].lastMessagePreview ?? ''),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PersonalChatPage(
                                chatId: filteredChats[index].id!,
                                currentUserId: _currentUserId!,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          if (_showCreateOptions) _buildCreateOptionsOverlay(),
          if (_showGroupCreation) _buildGroupCreationOverlay(),
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
        selectedItemColor: const Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
      ),
    );
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
                onTap: () => setState(() {
                  _showCreateOptions = false;
                  _showGroupCreation = true;
                }),
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Создать контакт'),
                onTap: () {
                  setState(() => _showCreateOptions = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactSelectionPage(
                        users: _allUsers,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCreationOverlay() {
  return Positioned.fill(
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showGroupCreation = false),
        ),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text('Создать'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: 
                    _groupImage != null ? FileImage(_groupImage!) : null,
                child: _groupImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _groupNameController,
                decoration: 
                    const InputDecoration(hintText: 'Название группы'),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Участники',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            ..._allUsers.map((user) => CheckboxListTile(
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text(user.appointment ?? ''),
              value: _selectedUsers[user.id!] ?? false,
              onChanged: (value) =>
                  setState(() => _selectedUsers[user.id!] = value!),
              secondary: CircleAvatar(
                radius: 20,
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatarUrl!.startsWith('http')
                              ? user.avatarUrl!
                              : '$_avatarBaseUrl${user.avatarUrl!.startsWith('/') 
                                  ? user.avatarUrl!.substring(1) 
                                  : user.avatarUrl}',
                          httpHeaders: 
                              {'Authorization': 'Bearer $accessToken'},
                          placeholder: (context, url) => Container(
                            color: Colors.grey,
                            child: const Icon(Icons.person, size: 20),
                          ),
                          errorWidget: (context, url, error) => 
                              const Icon(Icons.error, size: 20),
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      )
                    : const Icon(Icons.person),
              ),
            )),
          ],
        ),
      ),
    ),
  );
}
}
