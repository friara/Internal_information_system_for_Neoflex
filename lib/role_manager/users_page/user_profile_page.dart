import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/role_manager/users_page/date_format.dart';
import 'package:news_feed_neoflex/role_manager/users_page/phone_format.dart';

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
  bool _obscurePassword = true;
  Color colorForLabel = const Color.fromARGB(255, 104, 102, 102);

  late FocusNode _fioFocus;
  late FocusNode _phoneFocus;
  late FocusNode _loginFocus;
  late FocusNode _passwordFocus;

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

    _fioFocus = FocusNode();
    _phoneFocus = FocusNode();
    _loginFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _fioFocus.dispose();
    _phoneFocus.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();

    _fioController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = widget.userData['name'] ??
        widget.userData['fio'] ??
        'Новый пользователь';

    final updatedUser = {
      'name': name,
      'fio': _fioController.text,
      'phone': _phoneController.text,
      'position': _positionController.text,
      'role': _selectedRole,
      'login': _loginController.text,
      'password': _passwordController.text,
      'birthDate': _birthDateController.text,
    };

    widget.onSave(updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Данные пользователя сохранены'),
      duration: Duration(seconds: 2),
    ));
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isMacOS) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.path != null) {
            final newAvatar = File(file.path!);
            setState(() {
              _avatarImage = newAvatar;
            });
            widget.onAvatarChanged(newAvatar);
          }
        }
      } else if (Platform.isIOS || Platform.isAndroid) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (image != null) {
          final newAvatar = File(image.path);
          setState(() {
            _avatarImage = newAvatar;
          });
          widget.onAvatarChanged(newAvatar);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          if (file.path != null) {
            final newAvatar = File(file.path!);
            setState(() {
              _avatarImage = newAvatar;
            });
            widget.onAvatarChanged(newAvatar);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выборе изображения: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
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
                final userIdentifier =
                    widget.userData['name'] ?? widget.userData['fio'] ?? '';
                if (userIdentifier.isNotEmpty) {
                  widget.onDelete(widget.userData['fio']!);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Пользователь удален'),
                    duration: Duration(seconds: 2),
                  ));
                }
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Column(
          children: [
            AppBar(
              foregroundColor: Colors.purple,
              title: const Align(
                alignment: Alignment.center,
                child: Text("Профиль пользователя"),
              ),
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
                focusNode: _fioFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_phoneFocus),
                decoration: InputDecoration(
                  labelText: 'ФИО',
                  labelStyle: TextStyle(
                    color: colorForLabel,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_loginFocus),
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  labelStyle: TextStyle(
                    color: colorForLabel,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: '+7 (___) ___-__-__',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  RuPhoneInputFormatter(),
                  LengthLimitingTextInputFormatter(18)
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginController,
                focusNode: _loginFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                decoration: InputDecoration(
                  labelText: 'Логин',
                  labelStyle: TextStyle(
                    color: colorForLabel,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: TextStyle(
                      color: colorForLabel,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.purple, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.lock_open
                          : Icons.lock_outline),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 16),
              DateInput(
                controller: _birthDateController,
                labelText: 'Дата рождения',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Роль',
                  labelStyle: TextStyle(
                    color: colorForLabel,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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
                decoration: InputDecoration(
                  labelText: 'Должность',
                  labelStyle: TextStyle(
                    color: colorForLabel,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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
