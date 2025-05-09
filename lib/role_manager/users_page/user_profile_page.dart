import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:news_feed_neoflex/role_manager/users_page/date_format.dart';
import 'package:news_feed_neoflex/role_manager/users_page/phone_format.dart';
import 'package:openapi/openapi.dart';
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, String?> userData;
  final File? initialAvatar;
  final Function(UserDTO) onSave;
  final Function(int) onDelete;
  final Function(File?) onAvatarChanged;

  const UserProfilePage({
    super.key,
    required this.userData,
    this.initialAvatar,
    required this.onSave,
    required this.onDelete,
    required this.onAvatarChanged,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController _fioController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _loginController;
  late TextEditingController _birthDateController;
  String _selectedRole = 'ROLE_USER';
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool _obscurePassword = true;
  Color colorForLabel = const Color.fromARGB(255, 104, 102, 102);

  late String accessToken;
  late FocusNode _fioFocus;
  late FocusNode _phoneFocus;
  late FocusNode _loginFocus;

  static const Map<String, String> _roleDisplayNames = {
    'ROLE_USER': 'Сотрудник',
    'ROLE_ADMIN': 'Администратор',
  };

  static const List<String> _availableRoles = ['ROLE_USER', 'ROLE_ADMIN'];

  @override
  void initState() {
    super.initState();
    _initializeToken();
    _initializeControllers();
    _initializeAvatar();
    _initializeFocusNodes();
  }

  void _initializeToken() {
    GetIt.I<AuthRepositoryImpl>().getAccessToken().then((token) {
      accessToken = token ?? '';
    });
  }

  void _initializeControllers() {
    _fioController = TextEditingController(text: widget.userData['fio']);
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _positionController = TextEditingController(text: widget.userData['position']);
    _loginController = TextEditingController(text: widget.userData['login'] ?? '');
    _birthDateController = TextEditingController(text: widget.userData['birthDate'] ?? '');
    
    final roleFromData = widget.userData['role'];
    if (roleFromData != null && _availableRoles.contains(roleFromData)) {
      _selectedRole = roleFromData;
    }
  }

  void _initializeAvatar() {
    final avatarUrl = widget.userData['avatarUrl'];
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      _avatarImage = File(avatarUrl);
    } else {
      _avatarImage = widget.initialAvatar;
    }
  }

  void _initializeFocusNodes() {
    _fioFocus = FocusNode();
    _phoneFocus = FocusNode();
    _loginFocus = FocusNode();
  }

  @override
  void dispose() {
    _fioFocus.dispose();
    _phoneFocus.dispose();
    _loginFocus.dispose();
    _fioController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _loginController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    try {
      if (_fioController.text.isEmpty) throw Exception('ФИО обязательно');
      if (_loginController.text.isEmpty) throw Exception('Логин обязателен');

      final parts = _fioController.text.trim().split(RegExp(r'\s+'));
      Date? birthday;

      if (_birthDateController.text.isNotEmpty) {
        try {
          final dateTime = DateTime.parse(_birthDateController.text);
          birthday = Date(dateTime.year, dateTime.month, dateTime.day);
        } catch (e) {
          debugPrint('Ошибка парсинга даты: $e');
          throw Exception('Некорректный формат даты');
        }
      }

      final updatedUser = UserDTO((b) => b
        ..id = int.tryParse(widget.userData['id'] ?? '')
        ..firstName = parts.isNotEmpty ? parts[0] : null
        ..lastName = parts.length > 1 ? parts[1] : null
        ..patronymic = parts.length > 2 ? parts[2] : null
        ..phoneNumber = _phoneController.text.isNotEmpty ? _phoneController.text : null
        ..appointment = _positionController.text
        ..roleName = _selectedRole
        ..login = _loginController.text
        ..birthday = birthday
        ..avatarUrl = widget.userData['avatarUrl']);

      widget.onSave(updatedUser);
      _showSnackBar('Данные успешно сохранены');
    } catch (e) {
      _showSnackBar('Ошибка сохранения: ${e.toString()}', isError: true);
    }
  }

  Future<void> _pickImage() async {
    try {
      XFile? image;
      if (Platform.isIOS || Platform.isAndroid) {
        image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        image = result?.files.first.path != null ? XFile(result!.files.first.path!) : null;
      }
      if (image != null) await _uploadAndUpdateAvatar(File(image.path));
    } catch (e) {
      _showSnackBar('Ошибка выбора изображения: ${e.toString()}', isError: true);
    }
  }

  Future<void> _uploadAndUpdateAvatar(File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bytes = await imageFile.readAsBytes();
      final uploadRequest = UploadAvatarRequest((b) => b..file = bytes);
      final response = await GetIt.I<Openapi>()
          .getUserControllerApi()
          .uploadAvatar(uploadAvatarRequest: uploadRequest)
          .timeout(const Duration(seconds: 30));

      if (response.data != null) {
        setState(() => _avatarImage = imageFile);
        widget.onSave(UserDTO((b) => b
          ..id = int.tryParse(widget.userData['id'] ?? '')
          ..avatarUrl = response.data));
        _showSnackBar('Аватар обновлен');
      }
    } catch (e) {
      _showSnackBar('Ошибка загрузки: ${e.toString()}', isError: true);
    } finally {
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            child: const Text('Нет'),
            onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Да'),
            onPressed: () {
              final userId = int.tryParse(widget.userData['id'] ?? '');
              if (userId != null) {
                widget.onDelete(userId);
                Navigator.pop(context);
                Navigator.pop(context);
                _showSnackBar('Пользователь удален');
              }
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dio = GetIt.I<Dio>();
    String baseUrl = dio.options.baseUrl;

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    final avatarUrl = widget.userData['avatarUrl'];
    String? fullAvatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        fullAvatarUrl = avatarUrl;
      } else {
        final sanitizedPath = avatarUrl.startsWith('/') 
            ? avatarUrl.substring(1) 
            : avatarUrl;
        fullAvatarUrl = '$baseUrl/$sanitizedPath';
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            AppBar(
              foregroundColor: Colors.purple,
              title: const Align(
                alignment: Alignment.center,
                child: Text("Профиль пользователя")),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveProfile),
              ],
              surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatarWidget(fullAvatarUrl),
                  if (_avatarImage != null || fullAvatarUrl != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.purple),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_fioController, _fioFocus, 'ФИО', nextFocus: _phoneFocus),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildTextField(_loginController, _loginFocus, 'Логин'),
            const SizedBox(height: 16),
            DateInput(controller: _birthDateController, labelText: 'Дата рождения'),
            const SizedBox(height: 16),
            _buildRoleDropdown(),
            const SizedBox(height: 16),
            _buildTextField(_positionController, null, 'Должность'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Удалить профиль', style: TextStyle(color: Colors.red)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWidget(String? fullAvatarUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey),
      child: _avatarImage != null
          ? ClipOval(
              child: Image.file(_avatarImage!, fit: BoxFit.cover))
          : fullAvatarUrl != null
              ? FutureBuilder<String>(
                  future: GetIt.I<AuthRepositoryImpl>().getAccessToken(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return _buildPlaceholder();
                    return ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: fullAvatarUrl,
                        httpHeaders: {'Authorization': 'Bearer ${snapshot.data}'},
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) {
                          debugPrint('Ошибка загрузки: $error');
                          return _buildErrorWidget();
                        },
                        fit: BoxFit.cover,
                      ),
                    );
                  })
              : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() => const Icon(Icons.person, size: 60, color: Colors.white);
  Widget _buildErrorWidget() => const Icon(Icons.error, size: 60, color: Colors.red);

  Widget _buildTextField(
    TextEditingController controller,
    FocusNode? focusNode,
    String label, {
    FocusNode? nextFocus,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: nextFocus != null ? TextInputAction.next : null,
      onSubmitted: (_) => nextFocus != null 
          ? FocusScope.of(context).requestFocus(nextFocus)
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorForLabel),
        focusedBorder: _customBorder(),
        border: _customBorder(),
      ),
    );
  }

  InputBorder _customBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Colors.purple, width: 2),
  );

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => FocusScope.of(context).requestFocus(_loginFocus),
      decoration: InputDecoration(
        labelText: 'Телефон',
        labelStyle: TextStyle(color: colorForLabel),
        hintText: '+7 (___) ___-__-__',
        focusedBorder: _customBorder(),
        border: _customBorder(),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        RuPhoneInputFormatter(),
        LengthLimitingTextInputFormatter(18)
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Роль',
        labelStyle: TextStyle(color: colorForLabel),
        focusedBorder: _customBorder(),
        border: _customBorder(),
      ),
      items: _availableRoles
          .map((role) => DropdownMenuItem(
                value: role,
                child: Text(_roleDisplayNames[role] ?? role)))
          .toList(),
      onChanged: (value) => setState(() => _selectedRole = value!),
    );
  }
}