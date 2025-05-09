import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/role_manager/users_page/create_user_page.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'dart:io';
import 'package:openapi/openapi.dart';

class ListOfUsers extends StatefulWidget {
  const ListOfUsers({super.key});

  @override
  _ListOfUsersState createState() => _ListOfUsersState();
}

class _ListOfUsersState extends State<ListOfUsers> {
  final UserControllerApi userApi = GetIt.I<Openapi>().getUserControllerApi();
  List<UserDTO> _users = []; // Получаем пользователей
  List<UserDTO> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 3;
  final Map<String, File?> _userAvatars = {};
  bool _isSearchActive = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await userApi.getAllUsers();
      if (mounted) {
        setState(() {
          _users = response.data?.toList() ?? [];
          _filteredUsers = List.from(_users);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка загрузки пользователей: ${e.toString()}';
        });
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearchActive = query.isNotEmpty;
      _filteredUsers = _users.where((user) {
        final fio =
            '${user.firstName ?? ''} ${user.lastName ?? ''} ${user.patronymic ?? ''}'
                .toLowerCase();
        return fio.contains(query) ||
            (user.appointment?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearchActive = false;
      _filteredUsers = List.from(_users);
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/page1');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/page2');
    } else if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _updateUserData(UserDTO updatedUser) async {
    try {
      await userApi.updateCurrentUser(userDTO: updatedUser);
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка обновления пользователя: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      await userApi.adminDeleteUser(id: userId);
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка удаления пользователя: ${e.toString()}')),
      );
    }
  }

  Future<void> _addNewUser(Map<String, String?> userData) async {
    try {
      final parts = (userData['fio'] ?? '').split(' ');
      final createRequest = UserExtendedDTO((b) => b
        ..firstName = parts.isNotEmpty ? parts[0] : null
        ..lastName = parts.length > 1 ? parts[1] : null
        ..patronymic = parts.length > 2 ? parts[2] : null
        ..phoneNumber = userData['phone']
        ..appointment = userData['position']
        ..roleName = userData['role']
        ..login = userData['login']
        ..password = userData['password']
        ..birthday = userData['birthDate']?.isNotEmpty == true
            ? _parseDate(userData['birthDate']!)
            : null);

      await userApi.adminCreateUser(userExtendedDTO: createRequest);
      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка создания пользователя: ${e.toString()}')),
      );
    }
  }

  Date? _parseDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return Date(dateTime.year, dateTime.month, dateTime.day);
    } catch (e) {
      return null;
    }
  }

  void _updateAvatar(String userFio, File? avatarFile) {
    setState(() {
      _userAvatars[userFio] = avatarFile;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text("Список пользователей"),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateUserPage(
                          onSave: _addNewUser,
                        ),
                      ),
                    );
                  },
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск пользователей',
                labelStyle: const TextStyle(
                  color: Color.fromARGB(255, 104, 102, 102),
                ),
                hintText: 'Введите имя...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isSearchActive ? Icons.close : Icons.search),
                  onPressed: () {
                    if (_isSearchActive) {
                      _clearSearch();
                    } else {
                      _filterUsers();
                    }
                  },
                ),
              ),
              onSubmitted: (_) => _filterUsers(),
            ),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  final userFio =
                      '${user.firstName ?? ''} ${user.lastName ?? ''} ${user.patronymic ?? ''}';
                  final avatarFile = _userAvatars[userFio];
                  return ListTile(
                    title: Text(userFio),
                    subtitle: Text(user.appointment ?? ''),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          avatarFile != null ? FileImage(avatarFile) : null,
                      child: avatarFile == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            userData: {
                              'id': user.id?.toString() ?? '',
                              'fio':
                                  '${user.firstName ?? ''} ${user.lastName ?? ''} ${user.patronymic ?? ''}',
                              'phone': user.phoneNumber ?? '',
                              'position': user.appointment ?? '',
                              'role': user.roleName ?? 'Сотрудник',
                              'login': user.login ?? '',
                              'password': '',
                              'birthDate': user.birthday?.toString() ?? '',
                            },
                            initialAvatar: _userAvatars[userFio],
                            onSave: (UserDTO updatedUser) async {
                              final parts = [
                                updatedUser.firstName,
                                updatedUser.lastName,
                                updatedUser.patronymic
                              ]
                                  .where((part) => part != null)
                                  .join(' ')
                                  .split(' ');

                              final updatedUserWithChanges =
                                  updatedUser.rebuild((b) => b
                                    ..firstName =
                                        parts.isNotEmpty ? parts[0] : null
                                    ..lastName =
                                        parts.length > 1 ? parts[1] : null
                                    ..patronymic =
                                        parts.length > 2 ? parts[2] : null
                                    ..phoneNumber = updatedUser.phoneNumber
                                    ..appointment = updatedUser.appointment
                                    ..roleName = updatedUser.roleName
                                    ..login = updatedUser.login
                                    ..birthday = updatedUser.birthday);

                              await _updateUserData(updatedUserWithChanges);
                            },
                            onDelete: (userId) => _deleteUser(userId),
                            onAvatarChanged: (file) =>
                                _updateAvatar(userFio, file),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.computer), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message_sharp), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
