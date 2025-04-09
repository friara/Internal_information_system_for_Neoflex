import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/role_emloyee/chat_page/ContactSelectionPage.dart';
import 'dart:io';
import 'package:news_feed_neoflex/role_emloyee/chat_page/personal_chat_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.newGroup, this.newContact});

  final Map<String, dynamic>? newGroup;
  final String? newContact;

  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  int _selectedIndex = 2;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  List<String> _allChats =
      List.generate(10, (index) => 'Имя Пользователя $index');
  List<String> _filteredChats = [];
  bool _showCreateOptions = false;
  bool _showGroupCreation = false;
  Map<String, bool> _selectedUsers = {};
  File? _groupImage;
  final TextEditingController _groupNameController = TextEditingController();
  List<Map<String, dynamic>> _groups = [];

  bool _canCreateGroup() {
    return _groupNameController.text.isNotEmpty &&
        _selectedUsers.values.any((selected) => selected);
  }

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(_allChats);
    _selectedUsers = {for (var user in _allChats) user: false};

    if (widget.newGroup != null && widget.newGroup!['name'] != null) {
      _groups.insert(0, widget.newGroup!);
    }

    if (widget.newContact != null && !_allChats.contains(widget.newContact)) {
      _addNewChat(widget.newContact!);
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
    setState(() {
      _filteredChats = _allChats
          .where((chat) => chat.toLowerCase().contains(query))
          .toList();
      _isSearchActive = true;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredChats = List.from(_allChats);
      _isSearchActive = false;
    });
  }

  void _toggleCreateOptions() {
    setState(() {
      _showCreateOptions = !_showCreateOptions;
    });
  }

  void _startGroupCreation() {
    setState(() {
      _showCreateOptions = false;
      _showGroupCreation = true;
    });
  }

  void _createPersonalChat(String user) {
    _addNewChat(user); // Добавляем чат в список
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalChatPage(userId: user),
      ),
    );
  }

  void _addNewChat(String userName) {
    setState(() {
      _allChats.remove(userName);
      _filteredChats.remove(userName);

      _allChats.insert(0, userName);
      _filteredChats.insert(0, userName);
      _selectedUsers[userName] = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _groupImage = File(file.path!);
          });
        }
      } else {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _groupImage = File(image.path);
          });
        }
      }
    } catch (e) {
      print("Ошибка при выборе изображения: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при выборе изображения')),
      );
    }
  }

  void _createGroup() {
    if (!_canCreateGroup()) return;

    final selectedUsers = _selectedUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final newGroup = {
      'name': _groupNameController.text,
      'members': selectedUsers,
      'image': _groupImage,
      'isGroup': true,
    };

    setState(() {
      _groups.insert(0, newGroup); // Добавляем группу в начало списка
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(newGroup: newGroup),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/page1');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/page3',
          arguments: {'title': 'New title2'});
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildGroupAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: _groupImage != null
                ? kIsWeb
                    ? Image.memory(_groupImage!.readAsBytesSync()).image
                    : FileImage(_groupImage!)
                : null,
            child: _groupImage == null
                ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUserChats = _isSearchActive
        ? _allChats
            .where((chat) => chat
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList()
        : _allChats;

    final displayChats = [
      ..._groups
          .map((group) => {'name': group['name'], 'isGroup': true, ...group}),
      ...filteredUserChats.map((user) => {'name': user, 'isGroup': false}),
    ];

    if (_isSearchActive) {
      displayChats.removeWhere((chat) => !chat['name']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.purple,
        title: _showGroupCreation
            ? const Text("Создание группы")
            : const Text("Чаты"),
        actions: _showGroupCreation
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _toggleCreateOptions,
                ),
              ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    hintText: 'Поиск',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                    suffixIcon: IconButton(
                      icon: _isSearchActive
                          ? const Icon(Icons.close)
                          : const Icon(Icons.search),
                      onPressed:
                          _isSearchActive ? _clearSearch : _performSearch,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: displayChats.length,
                  itemBuilder: (context, index) {
                    final chat = displayChats[index];
                    return chat['isGroup']
                        ? _buildGroupChatTile(chat)
                        : _buildUserChatTile(chat['name']);
                  },
                ),
              ),
            ],
          ),
          if (_showCreateOptions)
            Positioned(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.group),
                        title: const Text('Создать группу'),
                        onTap: _startGroupCreation,
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Создать контакт'),
                        onTap: () {
                          setState(() {
                            _showCreateOptions = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactSelectionPage(
                                onContactSelected: (contact) {
                                  _addNewChat(contact);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showGroupCreation)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    AppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _showGroupCreation = false;
                          });
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: _canCreateGroup()
                              ? _createGroup
                              : () {
                                  if (_groupNameController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Введите название группы')),
                                    );
                                  } else if (!_selectedUsers.values
                                      .any((selected) => selected)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Выберите хотя бы одного участника')),
                                    );
                                  }
                                },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                _canCreateGroup() ? Colors.blue : Colors.grey,
                          ),
                          child: const Text('Создать'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildGroupAvatar(),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: _groupNameController,
                                decoration: const InputDecoration(
                                  hintText: 'Название группы',
                                  border: UnderlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Участники',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            ..._allChats.map((user) {
                              return CheckboxListTile(
                                title: Text(user),
                                subtitle: const Text('был(а) недавно'),
                                value: _selectedUsers[user] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedUsers[user] = value!;
                                  });
                                },
                                secondary: const CircleAvatar(
                                  backgroundImage: AssetImage(
                                      "assets/images/imageMyProfile.jpg"),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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

  Widget _buildGroupChatTile(Map<String, dynamic> group) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[200],
        backgroundImage: group['image'] != null
            ? kIsWeb
                ? Image.memory(group['image'].readAsBytesSync()).image
                : FileImage(group['image'])
            : null,
        child: group['image'] == null
            ? const Icon(Icons.group, size: 25, color: Colors.grey)
            : null,
      ),
      title: Text(group['name'] ?? 'Новая группа'),
      subtitle: Text(
        'Группа: ${(group['members'] as List<String>?)?.join(', ') ?? ''}',
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalChatPage(
              userId: group['name'],
              isGroup: true,
              groupMembers: group['members'],
              groupImage: group['image'],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserChatTile(String userName) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      leading: CircleAvatar(
        backgroundImage: AssetImage("assets/images/imageMyProfile.jpg"),
      ),
      title: Text(userName),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 200,
            height: 50,
            color: Colors.transparent,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('3', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalChatPage(userId: userName),
          ),
        );
      },
    );
  }
}
