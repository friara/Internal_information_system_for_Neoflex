import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/openapi.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupCreationPage extends StatefulWidget {
  final List<UserDTO> users;
  final String accessToken;
  final String avatarBaseUrl;

  const GroupCreationPage({
    super.key,
    required this.users,
    required this.avatarBaseUrl,
    required this.accessToken,
  });

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  final TextEditingController _groupNameController = TextEditingController();
  Map<int, bool> _selectedUsers = {};
  File? _groupImage;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Создание группы"),
        ),
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.purple,
            ),
            onPressed: () {
              if (_groupNameController.text.isEmpty ||
                  !_selectedUsers.values.any((v) => v)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Введите название группы и выберите участников')),
                );
                return;
              }

              final participantIds = _selectedUsers.entries
                  .where((e) => e.value)
                  .map((e) => e.key)
                  .toList();

              Navigator.pop(context, {
                'groupName': _groupNameController.text,
                'participantIds': participantIds,
                'groupImage': _groupImage,
              });
            },
            child: const Text('Создать'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(hintText: 'Название группы'),
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
            if (widget.users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Нет доступных пользователей для добавления'),
              ),
            ...widget.users.map((user) => CheckboxListTile(
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
                                  : '${widget.avatarBaseUrl}${user.avatarUrl!.startsWith('/') ? user.avatarUrl!.substring(1) : user.avatarUrl}',
                              httpHeaders: {
                                'Authorization': 'Bearer ${widget.accessToken}'
                              },
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
    );
  }
}
