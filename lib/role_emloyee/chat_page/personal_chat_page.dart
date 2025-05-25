import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:open_file/open_file.dart';
import 'package:openapi/openapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PersonalChatPage extends StatefulWidget {
  final int chatId;
  final bool isGroup;
  final int currentUserId;
  final VoidCallback? onBack;

  const PersonalChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    this.isGroup = false,
    required this.onBack,
  });

  @override
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final List<ChatFile> _selectedFiles = [];
  List<MessageDTO> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  ChatDTO? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  Map<int, UserDTO> _users = {};
  int? _editingMessageId;
  //final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _messageKeys = {};
  int? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    //_scrollController.dispose();
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

  // Future<void> _loadChatData() async {
  //   try {
  //     final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
  //     if (token == null) throw Exception('Нет токена авторизации');

  //     final chatApi = GetIt.I<Openapi>().getChatControllerApi();
  //     final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
  //     final userApi = GetIt.I<Openapi>().getUserControllerApi();

  //     final chatResponse = await chatApi.getChatById(
  //       id: widget.chatId,
  //       headers: {'Authorization': 'Bearer $token'},
  //     );

  //     final chatData = chatResponse.data;
  //     if (chatData == null) throw Exception('Чат не найден');

  //     final messagesResponse = await messageApi.getChatMessages(
  //       chatId: widget.chatId,
  //       headers: {'Authorization': 'Bearer $token'},
  //     );

  //     final messagesData = messagesResponse.data?.content?.toList() ?? [];

  //     final userIds =
  //         messagesData.map((m) => m.userId).whereType<int>().toSet();
  //     for (final userId in userIds) {
  //       final userResponse = await userApi.getUserById(
  //         id: userId,
  //         headers: {'Authorization': 'Bearer $token'},
  //       );
  //       if (userResponse.data != null) {
  //         _users[userId] = userResponse.data!;
  //       }
  //     }

  //     if (mounted) {
  //       setState(() {
  //         _chat = chatData;
  //         _messages = messagesData;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Ошибка загрузки чата: $e');
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //       _showErrorSnackbar('Ошибка загрузки чата');
  //     }
  //   }
  // }
  Future<void> _loadChatData() async {
    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final chatApi = GetIt.I<Openapi>().getChatControllerApi();
      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final userApi = GetIt.I<Openapi>().getUserControllerApi();

      // Загружаем данные чата
      final chatResponse = await chatApi.getChatById(
        id: widget.chatId,
        headers: {'Authorization': 'Bearer $token'},
      );

      final chatData = chatResponse.data;
      if (chatData == null) throw Exception('Чат не найден');

      // Загружаем сообщения чата
      final messagesResponse = await messageApi.getChatMessages(
        chatId: widget.chatId,
        headers: {'Authorization': 'Bearer $token'},
      );

      final messagesData = messagesResponse.data?.content?.toList() ?? [];

      // Собираем всех пользователей (авторов сообщений + участников чата)
      final userIds =
          messagesData.map((m) => m.userId).whereType<int>().toSet();

      // Добавляем текущего пользователя
      userIds.add(widget.currentUserId);

      // Загружаем данные всех пользователей
      for (final userId in userIds) {
        if (!_users.containsKey(userId)) {
          // Загружаем только если еще не загружены
          final userResponse = await userApi.getUserById(
            id: userId,
            headers: {'Authorization': 'Bearer $token'},
          );
          if (userResponse.data != null) {
            _users[userId] = userResponse.data!;
          }
        }
      }

      if (mounted) {
        setState(() {
          _chat = chatData;
          _messages = messagesData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки чата: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Ошибка загрузки чата');
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _selectedFiles.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();

      // Если есть и текст и файлы, отправляем отдельные сообщения
      if (_messageController.text.isNotEmpty && _selectedFiles.isNotEmpty) {
        // Сначала отправляем текстовое сообщение
        await messageApi.createMessage(
          chatId: widget.chatId,
          text: _messageController.text,
          headers: {'Authorization': 'Bearer $token'},
        );

        // Затем отправляем каждый файл отдельным сообщением
        for (final file in _selectedFiles) {
          final formData = FormData();
          final mimeType = _getMediaTypeForFile(file);
          final fileData = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
            contentType: mimeType,
          );
          formData.files.add(MapEntry('files', fileData));

          await messageApi.createMessage(
            chatId: widget.chatId,
            files: BuiltList([fileData]),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      } else if (_messageController.text.isNotEmpty) {
        // Только текст
        await messageApi.createMessage(
          chatId: widget.chatId,
          text: _messageController.text,
          headers: {'Authorization': 'Bearer $token'},
        );
      } else if (_selectedFiles.isNotEmpty) {
        // Только файлы - каждый файл отдельным сообщением
        for (final file in _selectedFiles) {
          final formData = FormData();
          final mimeType = _getMediaTypeForFile(file);
          final fileData = await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
            contentType: mimeType,
          );
          formData.files.add(MapEntry('files', fileData));

          await messageApi.createMessage(
            chatId: widget.chatId,
            files: BuiltList([fileData]),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }

      if (mounted) {
        setState(() {
          _messageController.clear();
          _selectedFiles.clear();
          _loadChatData();
        });
      }
    } catch (e) {
      debugPrint('Ошибка отправки сообщения: $e');
      if (mounted) {
        _showErrorSnackbar('Ошибка отправки сообщения: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

// Вспомогательный метод для получения MIME-типа
  String? _getMimeTypeFromFileType(String type) {
    switch (type) {
      case 'image':
        return 'image/jpeg';
      case 'video':
        return 'video/mp4';
      case 'document':
        return 'application/msword';
      case 'spreadsheet':
        return 'application/vnd.ms-excel';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  // Основные изменения в методах:

  // В методе _buildMessageItem добавлен вывод автора и даты для текстовых сообщений
  // Widget _buildMessageItem(MessageDTO message) {
  //   final isMe = message.userId == widget.currentUserId;
  //   final user = _users[message.userId ?? -1];
  //   final userName = user != null
  //       ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
  //       : 'Неизвестный';
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final hasText = message.text != null && message.text!.isNotEmpty;
  //   final hasFiles = message.files != null && message.files!.isNotEmpty;

  //   if (!_messageKeys.containsKey(message.id)) {
  //     _messageKeys[message.id!] = GlobalKey();
  //   }

  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     child: Column(
  //       crossAxisAlignment:
  //           isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  //       children: [
  //         if (!isMe)
  //           Padding(
  //             padding: const EdgeInsets.only(left: 50, bottom: 4),
  //             child: Text(
  //               userName,
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14,
  //                 color: Colors.white, // Имя автора белым
  //               ),
  //             ),
  //           ),
  //         GestureDetector(
  //           key: _messageKeys[message.id],
  //           onLongPress: () => _handleLongPress(message),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.end,
  //             mainAxisAlignment:
  //                 isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
  //             children: [
  //               if (!isMe) _buildUserAvatar(message.userId),
  //               Flexible(
  //                 child: Container(
  //                   constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
  //                   margin: EdgeInsets.only(
  //                     left: isMe ? 0 : 8,
  //                     right: isMe ? 8 : 0,
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: isMe
  //                         ? CrossAxisAlignment.end
  //                         : CrossAxisAlignment.start,
  //                     children: [
  //                       if (hasFiles) _buildMessageFiles(message),
  //                       if (hasText)
  //                         Container(
  //                           padding: const EdgeInsets.all(12),
  //                           decoration: BoxDecoration(
  //                             color: const Color.fromARGB(255, 165, 69, 182),
  //                             borderRadius: BorderRadius.only(
  //                               topLeft: const Radius.circular(12),
  //                               topRight: const Radius.circular(12),
  //                               bottomLeft: isMe
  //                                   ? const Radius.circular(12)
  //                                   : const Radius.circular(4),
  //                               bottomRight: isMe
  //                                   ? const Radius.circular(4)
  //                                   : const Radius.circular(12),
  //                             ),
  //                           ),
  //                           child: Column(
  //                             crossAxisAlignment: isMe
  //                                 ? CrossAxisAlignment.end
  //                                 : CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 message.text!,
  //                                 style: const TextStyle(
  //                                   fontSize: 15,
  //                                   color: Colors.white,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 4),
  //                               Text(
  //                                 DateFormat('HH:mm dd.MM.yyyy').format(
  //                                     message.createdWhen?.toLocal() ??
  //                                         DateTime.now().toLocal()),
  //                                 style: const TextStyle(
  //                                   fontSize: 11,
  //                                   color: Colors
  //                                       .white70, // Дата немного прозрачнее
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               if (isMe) _buildUserAvatar(message.userId),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

// В методе _buildMessageFiles добавлена дата поверх файла
  Widget _buildMessageItem(MessageDTO message) {
    final isMe = message.userId == widget.currentUserId;
    final user = _users[message.userId ?? -1];
    final userName = user != null
        ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
        : 'Неизвестный';
    final screenWidth = MediaQuery.of(context).size.width;
    final hasText = message.text != null && message.text!.isNotEmpty;
    final hasFiles = message.files != null && message.files!.isNotEmpty;

    if (!_messageKeys.containsKey(message.id)) {
      _messageKeys[message.id!] = GlobalKey();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 50, bottom: 4),
              child: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          GestureDetector(
            key: _messageKeys[message.id],
            onLongPress: () => _handleLongPress(message),
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
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (hasFiles) _buildMessageFiles(message),
                        if (hasText)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 165, 69, 182),
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
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.text!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('HH:mm dd.MM.yyyy').format(
                                      message.createdWhen?.toLocal() ??
                                          DateTime.now().toLocal()),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isMe) _buildUserAvatar(message.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFiles(MessageDTO message) {
    final isMe = message.userId == widget.currentUserId;
    final files = message.files!.toList();

    return Column(
      children: files.map((fileDto) {
        final chatFile = _convertFileDtoToChatFile(fileDto);
        final isImage = chatFile.type == 'image';
        final isVideo = chatFile.type == 'video';

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: isImage || isVideo
                  ? _buildMediaPreview(chatFile,
                      fileDto: fileDto, message: message)
                  : _buildFileItem(chatFile, fileDto: fileDto),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isMe)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        chatFile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('HH:mm dd.MM.yyyy').format(
                          message.createdWhen?.toLocal() ??
                              DateTime.now().toLocal()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

// Изменен метод _pickMedia для поддержки видео
  Future<void> _pickMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'mp4',
          'mov',
          'avi',
          'mkv'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(result.files.map((pf) => ChatFile(
                name: pf.name,
                path: pf.path,
                size: pf.size,
                type: _getFileType(pf.name),
              )));
        });
      }
    } catch (e) {
      debugPrint('Ошибка при выборе медиа: $e');
      _showErrorSnackbar('Ошибка при выборе медиа: ${e.toString()}');
    }
  }

  // Widget _buildMessageFiles(MessageDTO message) {
  //   final isMe = message.userId == widget.currentUserId;
  //   final files = message.files!.toList();

  //   return Column(
  //     children: files.map((fileDto) {
  //       final chatFile = _convertFileDtoToChatFile(fileDto);
  //       final isImage = chatFile.type == 'image';
  //       final isVideo = chatFile.type == 'video';

  //       return Stack(
  //         children: [
  //           Container(
  //             margin: const EdgeInsets.only(bottom: 8),
  //             child: isImage || isVideo
  //                 ? _buildMediaPreview(chatFile,
  //                     fileDto: fileDto, message: message)
  //                 : _buildFileItem(chatFile, fileDto: fileDto),
  //           ),
  //           // Имя и дата поверх медиа
  //           if (isImage || isVideo)
  //             Positioned(
  //               bottom: 8,
  //               left: 8,
  //               right: 8,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   if (!isMe)
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 8, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         color: Colors.black.withOpacity(0.5),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       child: Text(
  //                         chatFile.name,
  //                         style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 12,
  //                         ),
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: 8, vertical: 4),
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withOpacity(0.5),
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     child: Text(
  //                       DateFormat('HH:mm')
  //                           .format(message.createdWhen ?? DateTime.now()),
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //         ],
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildMediaPreview(ChatFile chatFile,
      {required FileDTO fileDto, required MessageDTO message}) {
    final isImage = chatFile.type == 'image';

    return GestureDetector(
      onTap: () => _openMediaInViewer(fileDto),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isImage
            ? FutureBuilder<String?>(
                future: GetIt.I<AuthRepositoryImpl>().getAccessToken(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      !snapshot.hasData) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return CachedNetworkImage(
                    imageUrl: _getFullFileUrl(fileDto.fileUrl!),
                    fit: BoxFit.cover,
                    httpHeaders: {
                      'Authorization': 'Bearer ${snapshot.data}',
                    },
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          onPressed: () {
                            final imageProvider = CachedNetworkImageProvider(
                              _getFullFileUrl(fileDto.fileUrl!),
                              headers: {
                                'Authorization': 'Bearer ${snapshot.data}'
                              },
                            );
                            imageProvider.evict().then((_) => setState(() {}));
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                height: 200,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Center(
                      child:
                          Icon(Icons.videocam, color: Colors.white, size: 50),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          chatFile.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _downloadFile(FileDTO file) async {
    try {
      // Запрашиваем разрешение на запись в хранилище
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorSnackbar('Необходимо разрешение на доступ к хранилищу');
        return;
      }

      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) {
        _showErrorSnackbar('Необходима авторизация');
        return;
      }

      // Получаем путь к папке загрузок
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        _showErrorSnackbar('Не удалось получить доступ к папке загрузок');
        return;
      }

      final savePath =
          '${directory.path}/${file.fileName ?? 'file_${DateTime.now().millisecondsSinceEpoch}'}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Скачивание ${file.fileName}...')),
      );

      final response = await Dio().download(
        _getFullFileUrl(file.fileUrl!),
        savePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          receiveTimeout: const Duration(minutes: 5),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Загружено $progress%')),
              );
          }
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Файл сохранен: ${directory.path}')),
          );

        // Открываем файл после скачивания
        await OpenFile.open(savePath);
      } else {
        _showErrorSnackbar('Ошибка скачивания файла: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Ошибка скачивания файла: $e');
      _showErrorSnackbar('Ошибка скачивания файла: ${e.toString()}');
    }
  }

  void _handleLongPress(MessageDTO message) {
    if (message.userId != widget.currentUserId) return;

    final hasText = message.text != null && message.text!.isNotEmpty;
    final hasFiles = message.files != null && message.files!.isNotEmpty;

    if (hasFiles) {
      _showFileOptionsDialog(message);
    } else if (hasText) {
      _showTextMessageOptionsDialog(message);
    }
  }

  // void _handleLongPress(MessageDTO message) {
  //   if (message.userId != widget.currentUserId) return; // Только свои сообщения

  //   final hasText = message.text != null && message.text!.isNotEmpty;
  //   final hasFiles = message.files != null && message.files!.isNotEmpty;

  //   if (hasFiles) {
  //     _showFileOptionsDialog(message);
  //   } else if (hasText) {
  //     _showTextMessageOptionsDialog(message);
  //   }
  // }

  void _showTextMessageOptionsDialog(MessageDTO message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _editingMessageId = message.id;
                  _messageController.text = message.text ?? '';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(message.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFileOptionsDialog(MessageDTO message) async {
    if (message.files == null || message.files!.isEmpty) return;

    final file = message.files!.first;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Скачать'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(message.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(ChatFile chatFile, {required FileDTO fileDto}) {
    final isImage = chatFile.type == 'image';

    return GestureDetector(
      onTap: () => _openFileDto(fileDto),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: FutureBuilder<String?>(
                      future: GetIt.I<AuthRepositoryImpl>().getAccessToken(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done ||
                            !snapshot.hasData) {
                          return Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 20),
                          );
                        }

                        return CachedNetworkImage(
                          imageUrl: _getFullFileUrl(fileDto.fileUrl!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          httpHeaders: {
                            'Authorization': 'Bearer ${snapshot.data}',
                          },
                          placeholder: (context, url) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 20),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey[300],
                            child: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () {
                                final imageProvider =
                                    CachedNetworkImageProvider(
                                  _getFullFileUrl(fileDto.fileUrl!),
                                  headers: {
                                    'Authorization': 'Bearer ${snapshot.data}'
                                  },
                                );
                                imageProvider
                                    .evict()
                                    .then((_) => setState(() {}));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Icon(
                    _getFileIcon(chatFile.type),
                    size: 30,
                    color: _getFileIconColor(chatFile.type),
                  ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 150,
                  child: Text(
                    chatFile.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (fileDto.fileSize != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatFileSize(fileDto.fileSize!),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openFileDto(FileDTO fileDto) async {
    if (fileDto.fileUrl == null) return;

    final fileType = _getFileTypeFromMime(fileDto.fileType);

    if (fileType == 'image') {
      await _openMediaInViewer(fileDto);
    } else {
      // Для других типов файлов скачиваем и открываем
      await _downloadAndOpenFile(fileDto);
    }
  }

  Future<void> _downloadAndOpenFile(FileDTO fileDto) async {
    try {
      final dir = await getTemporaryDirectory();
      final fileName = fileDto.fileName ?? 'file';
      final savePath = '${dir.path}/$fileName';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Открытие $fileName...')),
      );

      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) {
        _showErrorSnackbar('Необходима авторизация');
        return;
      }

      await Dio().download(
        _getFullFileUrl(fileDto.fileUrl!),
        savePath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final result = await OpenFile.open(savePath);

      if (result.type != ResultType.done) {
        // Если не удалось открыть в родном приложении, пробуем открыть в браузере
        final file = File(savePath);
        if (await file.exists()) {
          await file.delete();
        }

        // Скачиваем заново для открытия в браузере
        await Dio().download(
          _getFullFileUrl(fileDto.fileUrl!),
          savePath,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        // Открываем в браузере
        await OpenFile.open(savePath, type: 'application/octet-stream');
      }
    } catch (e) {
      debugPrint('Ошибка открытия файла: $e');
      _showErrorSnackbar('Ошибка открытия файла');
    }
  }

  String _getFullFileUrl(String path) {
    final dio = GetIt.I<Dio>();
    String baseUrl = dio.options.baseUrl;
    if (!baseUrl.endsWith('/') && !path.startsWith('/')) {
      baseUrl += '/';
    }
    return baseUrl + path;
  }

  // Widget _buildMediaPreview(ChatFile chatFile, {required FileDTO fileDto}) {
  //   final isImage = chatFile.type == 'image';

  //   return GestureDetector(
  //     onTap: () => _openMediaInViewer(fileDto),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(8),
  //       child: isImage
  //           ? FutureBuilder<String?>(
  //               future: GetIt.I<AuthRepositoryImpl>().getAccessToken(),
  //               builder: (context, snapshot) {
  //                 if (snapshot.connectionState != ConnectionState.done ||
  //                     !snapshot.hasData) {
  //                   return Container(
  //                     color: Colors.grey[200],
  //                     child: const Center(child: CircularProgressIndicator()),
  //                   );
  //                 }

  //                 return AspectRatio(
  //                   aspectRatio: 1, // Квадратное соотношение сторон
  //                   child: CachedNetworkImage(
  //                     imageUrl: _getFullFileUrl(fileDto.fileUrl!),
  //                     fit: BoxFit.contain,
  //                     httpHeaders: {
  //                       'Authorization': 'Bearer ${snapshot.data}',
  //                     },
  //                     placeholder: (context, url) => Container(
  //                       color: Colors.grey[200],
  //                       child: const Center(child: CircularProgressIndicator()),
  //                     ),
  //                     errorWidget: (context, url, error) => Container(
  //                       color: Colors.grey[200],
  //                       child: Center(
  //                         child: IconButton(
  //                           icon: const Icon(Icons.refresh, color: Colors.red),
  //                           onPressed: () {
  //                             final imageProvider = CachedNetworkImageProvider(
  //                               _getFullFileUrl(fileDto.fileUrl!),
  //                               headers: {
  //                                 'Authorization': 'Bearer ${snapshot.data}'
  //                               },
  //                             );
  //                             imageProvider
  //                                 .evict()
  //                                 .then((_) => setState(() {}));
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             )
  //           : Container(
  //               height: 200,
  //               color: Colors.black,
  //               child: Stack(
  //                 fit: StackFit.expand,
  //                 children: [
  //                   const Center(
  //                     child:
  //                         Icon(Icons.videocam, color: Colors.white, size: 50),
  //                   ),
  //                   Positioned(
  //                     bottom: 8,
  //                     right: 8,
  //                     child: Container(
  //                       padding: const EdgeInsets.all(4),
  //                       decoration: BoxDecoration(
  //                         color: Colors.black54,
  //                         borderRadius: BorderRadius.circular(4),
  //                       ),
  //                       child: Text(
  //                         chatFile.name,
  //                         style: const TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //     ),
  //   );
  // }

  Future<void> _openMediaInViewer(FileDTO file) async {
    if (file.fileUrl == null) return;

    final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
    if (token == null) return;

    final isImage = file.fileType?.startsWith('image/') ?? false;

    if (isImage) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CachedNetworkImage(
                imageUrl: _getFullFileUrl(file.fileUrl!),
                httpHeaders: {
                  'Authorization': 'Bearer $token',
                },
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    } else {
      _showErrorSnackbar('Просмотр видео временно недоступен');
    }
  }

  // Future<void> _downloadFile(FileDTO file) async {
  //   try {
  //     // Запрашиваем разрешение на запись в хранилище
  //     final status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       _showErrorSnackbar('Необходимо разрешение на доступ к хранилищу');
  //       return;
  //     }

  //     final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
  //     if (token == null) {
  //       _showErrorSnackbar('Необходима авторизация');
  //       return;
  //     }

  //     // Получаем путь к папке загрузок
  //     final directory = Directory('/storage/emulated/0/Download');
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }

  //     final savePath = '${directory.path}/${file.fileName ?? 'file'}';

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Скачивание ${file.fileName}...')),
  //     );

  //     await Dio().download(
  //       _getFullFileUrl(file.fileUrl!),
  //       savePath,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //       onReceiveProgress: (received, total) {
  //         if (total != -1) {
  //           final progress = (received / total * 100).toStringAsFixed(0);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Загружено $progress%')),
  //           );
  //         }
  //       },
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Файл сохранен в Загрузки')),
  //     );
  //   } catch (e) {
  //     debugPrint('Ошибка скачивания файла: $e');
  //     _showErrorSnackbar('Ошибка скачивания файла');
  //   }
  // }

  String _getFileTypeFromMime(String? mimeType) {
    if (mimeType == null) return 'file';

    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType == 'application/pdf') return 'pdf';
    if (mimeType == 'application/msword' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return 'document';
    }
    if (mimeType == 'application/vnd.ms-excel' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
      return 'spreadsheet';
    }

    return 'file';
  }

  IconData _getFileIcon(String? fileType) {
    switch (fileType) {
      case 'document':
        return Icons.description;
      case 'spreadsheet':
        return Icons.table_chart;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image; // Используем иконку для изображений
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(String? fileType) {
    switch (fileType) {
      case 'document':
        return Colors.blue;
      case 'spreadsheet':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'image':
        return Colors.amber; // Цвет для иконки изображения
      case 'video':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // В классе _PersonalChatPageState добавьте этот метод для конвертации
  ChatFile _convertFileDtoToChatFile(FileDTO fileDto) {
    return ChatFile(
      name: fileDto.fileName ?? 'Файл',
      url: fileDto.fileUrl,
      type: _getFileTypeFromMime(fileDto.fileType),
      size: null, // Размер неизвестен для FileDTO
    );
  }

// Обновленный метод для отображения файлов в сообщениях
  // Widget _buildMessageFiles(List<FileDTO> files) {
  //   return Column(
  //     children: files.map((fileDto) {
  //       final chatFile = _convertFileDtoToChatFile(fileDto);
  //       final isImage = chatFile.type == 'image';
  //       final isVideo = chatFile.type == 'video';

  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 8),
  //         child: isImage || isVideo
  //             ? _buildMediaPreview(chatFile, fileDto: fileDto)
  //             : _buildFileItem(chatFile, fileDto: fileDto),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildSelectedFilesPreview() {
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100, // Фиксированная высота для горизонтального списка
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Горизонтальная прокрутка
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8), // Отступ между элементами
            child: Stack(
              children: [
                Container(
                  width: 80, // Фиксированная ширина для каждого элемента
                  height: 80, // Фиксированная высота для каждого элемента
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildFileThumbnail(file),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileThumbnail(ChatFile file) {
    final isImage = file.type == 'image' && file.path != null;
    final isVideo = file.type == 'video';

    return InkWell(
      onTap: () => _previewSelectedFile(file),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(file.path!),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            )
          else if (isVideo)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white, size: 30),
              ),
            )
          else
            Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getFileIcon(file.type),
                    size: 30,
                    color: _getFileIconColor(file.type),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.name.length > 10
                        ? '${file.name.substring(0, 7)}...${file.name.split('.').last}'
                        : file.name,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _previewSelectedFile(ChatFile file) async {
    if (file.path == null) return;

    final isImage = file.type == 'image';
    final isVideo = file.type == 'video';

    if (isImage) {
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Image.file(File(file.path!)),
              ),
            ),
          ));
    } else if (isVideo) {
      _showErrorSnackbar('Просмотр видео временно недоступен');
    } else {
      await _openFile(file);
    }
  }

  Future<void> _showFilePickerDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тип файла'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Файл'),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Фото/Видео'),
              onTap: () => Navigator.pop(context, 'media'),
            ),
          ],
        ),
      ),
    );

    if (result == 'file') {
      await _pickFiles();
    } else if (result == 'media') {
      await _pickMedia();
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(result.files.map((pf) => ChatFile(
                name: pf.name,
                path: pf.path,
                size: pf.size,
                type: _getFileType(pf.name),
              )));
        });
      }
    } catch (e) {
      debugPrint('Ошибка при выборе файла: $e');
      _showErrorSnackbar('Ошибка при выборе файла: ${e.toString()}');
    }
  }

  // Future<void> _pickMedia() async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       allowMultiple: true,
  //       type: FileType.image,
  //       allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'],
  //     );

  //     if (result != null && result.files.isNotEmpty) {
  //       setState(() {
  //         _selectedFiles.addAll(result.files.map((pf) => ChatFile(
  //               name: pf.name,
  //               path: pf.path,
  //               size: pf.size,
  //               type: _getFileType(pf.name),
  //             )));
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Ошибка при выборе медиа: $e');
  //     _showErrorSnackbar('Ошибка при выборе медиа: ${e.toString()}');
  //   }
  // }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return 'image';
    if (['mp4', 'mov', 'avi'].contains(ext)) return 'video';
    if (['pdf'].contains(ext)) return 'document';
    return 'file';
  }

  MediaType? _getMediaTypeForFile(ChatFile file) {
    switch (file.type) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'avi');
      default:
        return MediaType('application', 'octet-stream');
    }
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

  Future<void> _updateMessage(int messageId) async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) throw Exception('Сообщение не найдено');

      if (_messages[messageIndex].userId != widget.currentUserId) {
        throw Exception('Вы не являетесь автором этого сообщения');
      }

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final response = await messageApi.updateMessage(
        chatId: widget.chatId,
        messageId: messageId,
        text: _messageController.text,
        files: null,
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
            backgroundColor: Colors.grey,
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
      final authRepo = GetIt.I<AuthRepositoryImpl>();
      final token = await authRepo.getAccessToken();
      if (token == null) {
        _showErrorSnackbar('Нет токена авторизации');
        return;
      }

      final messageExists = _messages.any((m) => m.id == messageId);
      if (!messageExists) {
        _showErrorSnackbar('Сообщение не найдено в локальном кеше');
        return;
      }

      final currentUserId = _getUserIdFromToken(token);
      if (currentUserId == null) {
        _showErrorSnackbar('Не удалось определить пользователя из токена');
        return;
      }

      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      final message = _messages[messageIndex];

      if (message.userId != currentUserId) {
        _showErrorSnackbar('Вы можете удалять только свои сообщения');
        return;
      }

      debugPrint('Пытаемся удалить сообщение: '
          'ID сообщения: $messageId, '
          'ID пользователя из токена: $currentUserId, '
          'Автор сообщения: ${message.userId}');

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      await messageApi.deleteMessage(
        chatId: widget.chatId,
        messageId: messageId,
        headers: {
          'Authorization': 'Bearer $token',
          'X-User-Id': currentUserId.toString(),
        },
      );

      if (mounted) {
        setState(() {
          _messages.removeAt(messageIndex);
          _selectedMessageId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сообщение удалено'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('Ошибка удаления сообщения (Dio): ${e.response?.data}');
      _showErrorSnackbar('Ошибка удаления: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Ошибка удаления сообщения: $e');
      _showErrorSnackbar('Ошибка удаления сообщения');
    }
  }

  int? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      final userIdStr = payload['sub'];
      if (userIdStr is! String || !userIdStr.startsWith('user')) return null;

      return int.tryParse(userIdStr.replaceAll('user', ''));
    } catch (e) {
      debugPrint('Ошибка декодирования токена: $e');
      return null;
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

  Future<void> _openFile(ChatFile file) async {
    if (file.path != null) {
      await OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_selectedMessageId != null) {
          setState(() => _selectedMessageId = null);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Column(
            children: [
              AppBar(
                foregroundColor: Colors.purple,
                surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
                title: Text(
                    _chat?.chatName ?? (widget.isGroup ? 'Группа' : 'Чат')),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (widget.onBack != null) widget.onBack!();
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey,
              ),
            ],
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
                          //controller: _scrollController,
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageItem(_messages[index]),
                        ),
                      ),
                      _buildSelectedFilesPreview(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _showFilePickerDialog,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: _editingMessageId != null
                                      ? 'Редактируете сообщение...'
                                      : 'Сообщение',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(255, 104, 102, 102),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.purple, width: 2),
                                    borderRadius: BorderRadius.circular(10.0),
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

class ChatFile {
  final String name;
  final String? path;
  final String? url;
  final String type;
  final int? size;

  ChatFile({
    required this.name,
    this.path,
    this.url,
    this.type = 'file',
    this.size,
  });

  String? get extension {
    if (name.contains('.')) {
      return name.split('.').last.toLowerCase();
    }
    return type?.split('/').last.toLowerCase();
  }
}
