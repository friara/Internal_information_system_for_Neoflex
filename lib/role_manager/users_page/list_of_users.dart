import 'package:flutter/material.dart';
import 'package:news_feed_neoflex/role_manager/users_page/create_user_page.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ListOfUsers extends StatefulWidget {
  @override
  _ListOfUsersState createState() => _ListOfUsersState();
}

class _ListOfUsersState extends State<ListOfUsers> {
  final List<Map<String, String>> _users = List.generate(20, (index) {
    return {
      'name': 'Имя пользователя $index',
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

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['name']!.toLowerCase().contains(query);
      }).toList();
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
      int index = _users.indexWhere((u) => u['name'] == updatedUser['name']);
      if (index != -1) {
        _users[index] = updatedUser;
        _filterUsers();
      }
    });
  }

  void _deleteUser(String userName) {
    setState(() {
      _users.removeWhere((user) => user['name'] == userName);
      _userAvatars.remove(userName);
      _filterUsers();
    });
  }

  void _addNewUser(Map<String, String> newUser) {
    setState(() {
      _users.insert(0, newUser);
      _filterUsers();
    });
  }

  void _updateAvatar(String userName, File? avatarFile) {
    setState(() {
      _userAvatars[userName] = avatarFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список пользователей'),
        automaticallyImplyLeading: false,
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск пользователей',
                hintText: 'Введите имя...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final avatarFile = _userAvatars[user['name']];

                return ListTile(
                  title: Text(user['name']!),
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
                          initialAvatar: _userAvatars[user['name']],
                          onSave: _updateUserData,
                          onDelete: _deleteUser,
                          onAvatarChanged: (file) =>
                              _updateAvatar(user['name']!, file),
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
