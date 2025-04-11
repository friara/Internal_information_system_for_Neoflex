import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, String> userData;
  final File? initialAvatar;
  final Function(Map<String, String>) onSave;
  final Function(String) onDelete;
  final Function(File?) onAvatarChanged;

  const UserProfilePage({
    Key? key,
    required this.userData,
    this.initialAvatar,
    required this.onSave,
    required this.onDelete,
    required this.onAvatarChanged,
  }) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController _fioController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late TextEditingController _birthDateController;
  late String _selectedRole;
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fioController = TextEditingController(text: widget.userData['fio']);
    _phoneController =
        TextEditingController(text: widget.userData['phone'] ?? '');
    _positionController =
        TextEditingController(text: widget.userData['position']);
    _loginController =
        TextEditingController(text: widget.userData['login'] ?? '');
    _passwordController =
        TextEditingController(text: widget.userData['password'] ?? '');
    _birthDateController =
        TextEditingController(text: widget.userData['birthDate'] ?? '');
    _selectedRole = widget.userData['role'] ?? 'Сотрудник';
    _avatarImage = widget.initialAvatar;
  }

  @override
  void dispose() {
    _fioController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedUser = {
      'name': widget.userData['name']!,
      'fio': _fioController.text,
      'phone': _phoneController.text,
      'position': _positionController.text,
      'role': _selectedRole,
      'login': _loginController.text,
      'password': _passwordController.text,
      'birthDate': _birthDateController.text,
    };

    widget.onSave(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Данные пользователя сохранены'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day}.${picked.month}.${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final newAvatar = File(image.path);
      setState(() {
        _avatarImage = newAvatar;
      });
      widget.onAvatarChanged(newAvatar);
    }
  }

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение удаления'),
          content: const Text(
              'Вы уверены, что хотите удалить данные этого пользователя?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Да'),
              onPressed: () {
                widget.onDelete(widget.userData['name']!);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пользователь удален'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: _avatarImage == null ? Colors.grey : null,
                  backgroundImage:
                      _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child: _avatarImage == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fioController,
                decoration: const InputDecoration(
                  labelText: 'ФИО',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  labelText: 'Логин',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Дата рождения',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Роль',
                  border: OutlineInputBorder(),
                ),
                items: ['Сотрудник', 'Менеджер']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Должность',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Удалить профиль',
                  style: TextStyle(color: Colors.red),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
