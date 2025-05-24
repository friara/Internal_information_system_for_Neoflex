import 'dart:io';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:openapi/openapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class PersonalChatPage extends StatefulWidget {
  final int chatId;
  final bool isGroup;
  final int currentUserId;

  const PersonalChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.isGroup = false,
  });

  @override
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final List<PlatformFile> _selectedFiles = [];
  List<MessageDTO> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  ChatDTO? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  Map<int, UserDTO> _users = {};
  int? _editingMessageId;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _messageKeys = {};
  int? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _loadChatData();
    } catch (e) {
      debugPrint('Ошибка инициализации: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Ошибка загрузки чата');
      }
    }
  }

  Future<void> _loadChatData() async {
    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final chatApi = GetIt.I<Openapi>().getChatControllerApi();
      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final userApi = GetIt.I<Openapi>().getUserControllerApi();

      final chatResponse = await chatApi.getChatById(
        id: widget.chatId,
        headers: {'Authorization': 'Bearer $token'},
      );

      final chatData = chatResponse.data;
      if (chatData == null) throw Exception('Чат не найден');

      final messagesResponse = await messageApi.getChatMessages(
        chatId: widget.chatId,
        headers: {'Authorization': 'Bearer $token'},
      );

      final messagesData = messagesResponse.data?.content?.toList() ?? [];

      final userIds =
          messagesData.map((m) => m.userId).whereType<int>().toSet();
      for (final userId in userIds) {
        final userResponse = await userApi.getUserById(
          id: userId,
          headers: {'Authorization': 'Bearer $token'},
        );
        if (userResponse.data != null) {
          _users[userId] = userResponse.data!;
        }
      }

      if (mounted) {
        setState(() {
          _chat = chatData;
          _messages = messagesData;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки чата: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Ошибка загрузки чата');
      }
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'zip',
          'rar',
          'mp3',
          'wav',
          'mp4',
          'mov'
        ],
      );

      if (result != null) {
        setState(() => _selectedFiles.addAll(result.files));
      }
    } catch (e) {
      debugPrint('Ошибка при выборе файла: $e');
      _showErrorSnackbar('Ошибка при выборе файла');
    }
  }

  MediaType? _getMediaTypeForFile(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    switch (ext) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'octet-stream');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case 'pptx':
        return MediaType('application',
            'vnd.openxmlformats-officedocument.presentationml.presentation');
      case 'zip':
        return MediaType('application', 'zip');
      case 'rar':
        return MediaType('application', 'x-rar-compressed');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDeleteDialog(int messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Вы уверены, что хотите удалить это сообщение?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteMessage(messageId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _selectedFiles.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final formData = FormData();

      if (_messageController.text.isNotEmpty) {
        formData.fields.add(MapEntry('text', _messageController.text));
      }

      for (final file in _selectedFiles) {
        final mimeType = _getMediaTypeForFile(file);
        final fileData = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
          contentType: mimeType,
        );
        formData.files.add(MapEntry('files', fileData));
      }

      final response = await messageApi.createMessage(
        chatId: widget.chatId,
        text: _messageController.text,
        files: _selectedFiles.isNotEmpty
            ? BuiltList<MultipartFile>(
                formData.files.map((e) => e.value).toList())
            : null,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.data != null && mounted) {
        setState(() {
          _messages.insert(0, response.data!);
          _messageController.clear();
          _selectedFiles.clear();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Ошибка отправки сообщения: $e');
      if (mounted) {
        _showErrorSnackbar('Ошибка отправки сообщения');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _updateMessage(int messageId) async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      // 1. Проверяем авторство локально
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) throw Exception('Сообщение не найдено');

      if (_messages[messageIndex].userId != widget.currentUserId) {
        throw Exception('Вы не являетесь автором этого сообщения');
      }

      // 2. Используем стандартный API клиент
      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final response = await messageApi.updateMessage(
        chatId: widget.chatId,
        messageId: messageId,
        text: _messageController.text,
        files: null, // или список файлов, если нужно
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );

      if (response.data != null && mounted) {
        setState(() {
          _messages[messageIndex] = response.data!;
          _editingMessageId = null;
          _messageController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сообщение обновлено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка редактирования сообщения: $e');
      if (mounted) {
        _showErrorSnackbar(
          e.toString().contains('автором')
              ? 'Вы можете редактировать только свои сообщения'
              : 'Ошибка при обновлении сообщения',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    try {
      // Проверяем, является ли текущий пользователь автором сообщения
      final message = _messages.firstWhere((m) => m.id == messageId);
      if (message.userId != widget.currentUserId) {
        _showErrorSnackbar('Вы можете удалять только свои сообщения');
        return;
      }

      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      await messageApi.deleteMessage(
        chatId: widget.chatId,
        messageId: messageId,
        headers: {'Authorization': 'Bearer $token'},
      );

      setState(() {
        _messages.removeWhere((m) => m.id == messageId);
      });
    } catch (e) {
      debugPrint('Ошибка удаления сообщения: $e');
      _showErrorSnackbar('Ошибка удаления сообщения');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildUserAvatar(int? userId) {
    if (userId == null || _users[userId]?.avatarUrl == null) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    final user = _users[userId]!;
    final dio = GetIt.I<Dio>();
    String baseUrl = dio.options.baseUrl;

    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    String avatarPath = user.avatarUrl!;
    if (avatarPath.startsWith('/')) {
      avatarPath = avatarPath.substring(1);
    }

    final avatarUrl = '$baseUrl$avatarPath';

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        errorWidget: (context, url, error) {
          return const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.error, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(MessageDTO message) {
    final isMe = message.userId == widget.currentUserId;
    final user = message.userId != null ? _users[message.userId!] : null;
    final userName = user != null
        ? '${user.firstName ?? ''} ${user.lastName ?? ''}'
        : 'Аноним';
    final screenWidth = MediaQuery.of(context).size.width;

    // Создаем ключ для сообщения, если его еще нет
    if (!_messageKeys.containsKey(message.id)) {
      _messageKeys[message.id!] = GlobalKey();
    }

    return GestureDetector(
      key: _messageKeys[message.id],
      onTap: isMe
          ? () {
              setState(() {
                _selectedMessageId =
                    _selectedMessageId == message.id ? null : message.id;
              });
            }
          : null,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe) _buildUserAvatar(message.userId),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                    margin: EdgeInsets.only(
                      left: isMe ? 0 : 8,
                      right: isMe ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe
                            ? const Radius.circular(12)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        if (message.text != null)
                          Text(
                            message.text!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(
                                  message.createdWhen ?? DateTime.now()),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (isMe) _buildUserAvatar(message.userId),
              ],
            ),
          ),
          if (_selectedMessageId == message.id && isMe)
            Positioned(
              right: isMe ? 0 : null,
              left: isMe ? null : 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildOptionButton(
                      'Редактировать',
                      Icons.edit,
                      () {
                        setState(() {
                          _editingMessageId = message.id;
                          _messageController.text = message.text ?? '';
                          _selectedMessageId = null;
                        });
                      },
                    ),
                    _buildOptionButton(
                      'Удалить',
                      Icons.delete,
                      () {
                        setState(() => _selectedMessageId = null);
                        _showDeleteDialog(message.id!);
                      },
                      isDelete: true,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, IconData icon, VoidCallback onPressed,
      {bool isDelete = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDelete ? Colors.red : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isDelete ? Colors.red : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Закрываем меню при нажатии вне сообщения
        if (_selectedMessageId != null) {
          setState(() => _selectedMessageId = null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_chat?.chatName ?? (widget.isGroup ? 'Группа' : 'Чат')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _chat == null
                ? const Center(child: Text('Чат не найден или нет доступа'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageItem(_messages[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _pickFiles,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: _editingMessageId != null
                                      ? 'Редактируете сообщение...'
                                      : 'Сообщение',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: _isSending
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.send),
                              onPressed: _isSending
                                  ? null
                                  : _editingMessageId != null
                                      ? () => _updateMessage(_editingMessageId!)
                                      : _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
