import 'package:flutter/material.dart';
import 'package:news_feed_neoflex/role_manager/users_page/create_user_page.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'dart:io';

class ListOfUsers extends StatefulWidget {
  const ListOfUsers({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListOfUsersState createState() => _ListOfUsersState();
}

class _ListOfUsersState extends State<ListOfUsers> {
  final List<Map<String, String>> _users = List.generate(20, (index) {
    return {
      'name': 'user_$index',
      'fio': 'Бублик Петрович $index',
      'phone': '+7 (${index.toString().padLeft(3, '0')}) 123-45-67',
      'position': 'Должность $index',
      'role': index % 2 == 0 ? 'Сотрудник' : 'Менеджер',
      'login': 'user$index',
      'password': 'password$index',
      'birthDate': '01.01.199${index % 10}',
    };
  });

  List<Map<String, String>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 3;
  final Map<String, File?> _userAvatars = {};
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearchActive = query.isNotEmpty;
      _filteredUsers = _users.where((user) {
        return user['fio']!.toLowerCase().contains(query) ||
            user['position']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearchActive = false;
      _filteredUsers = _users;
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

  void _updateUserData(Map<String, String> updatedUser) {
    setState(() {
      final userIdentifier = updatedUser['name'] ?? updatedUser['fio'];

      int index = _users.indexWhere((u) =>
          (u['name'] != null && u['name'] == userIdentifier) ||
          (u['fio'] != null && u['fio'] == userIdentifier));

      if (index != -1) {
        _users[index] = updatedUser;
        if (_isSearchActive) {
          _filterUsers();
        } else {
          _filteredUsers = List.from(_users);
        }
      }
    });
  }

  void _deleteUser(String userName) {
    setState(() {
      _users.removeWhere((user) => user['name'] == userName);
      _userAvatars.remove(userName);
      if (_isSearchActive) {
        _filterUsers();
      } else {
        _filteredUsers = List.from(_users);
      }
    });
  }

  void _addNewUser(Map<String, String> newUser) {
    setState(() {
      _users.insert(0, newUser);
      _filterUsers();
    });
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
              //scrolledUnderElevation: 0, // Убирает тень при прокрутке
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
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _isSearchActive ? Icons.close : Icons.search,
                      ),
                      onPressed: () {
                        if (_isSearchActive) {
                          _clearSearch();
                        } else {
                          _filterUsers();
                        }
                      })),
              onSubmitted: (_) => _filterUsers(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final avatarFile = _userAvatars[user['fio']];
                return ListTile(
                  title: Text(user['fio']!),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        avatarFile != null ? FileImage(avatarFile) : null,
                    child: avatarFile == null
                        ? const Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfilePage(
                          userData: user,
                          initialAvatar: _userAvatars[user['fio']],
                          onSave: _updateUserData,
                          onDelete: _deleteUser,
                          onAvatarChanged: (file) =>
                              _updateAvatar(user['fio']!, file),
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
        selectedItemColor: Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
