import 'dart:io';
import 'dart:typed_data';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:open_file/open_file.dart';
import 'package:openapi/openapi.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'message_model.dart';
import 'file_utils.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // Добавьте это

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
  // ignore: library_private_types_in_public_api
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final List<PlatformFile> _selectedFiles = [];
  List<MessageDTO> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  ChatDTO? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  final List<String> _allowedExtensions = [
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
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
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

      try {
        // Загрузка информации о чате
        final chatResponse = await chatApi.getChatById(
          id: widget.chatId,
          headers: {'Authorization': 'Bearer $token'},
        );

        final chatData = chatResponse.data;
        if (chatData == null) {
          throw Exception('Чат не найден');
        }

        // Загрузка сообщений для конкретного чата
        final messagesResponse = await messageApi.getChatMessages(
          chatId: widget.chatId,
          headers: {'Authorization': 'Bearer $token'},
        );

        final messagesData = messagesResponse.data?.content?.toList() ?? [];

        if (mounted) {
          setState(() {
            _chat = chatData;
            _messages = messagesData;
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 500) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Нет доступа к этому чату'),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки чата: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Ошибка загрузки чата: ${e.toString()}');
        Navigator.pop(context);
      }
    }
  }

  MediaType? getMediaTypeForFile(PlatformFile file) {
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
        return MediaType('application',
            'vnd.openxmlformats-officedocument.wordprocessingml.document');
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
        // Если тип неизвестен, используем octet-stream
        return MediaType('application', 'octet-stream');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Реализация прокрутки, если у вас есть ScrollController
      // Например, если у вас ListView.builder с контроллером:
      // _scrollController.animateTo(
      //   _scrollController.position.maxScrollExtent,
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
    });
  }

  // Future<void> _sendMessage() async {
  //   if (_messageController.text.isEmpty && _selectedFiles.isEmpty) return;

  //   setState(() => _isSending = true);

  //   try {
  //     final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
  //     if (token == null) throw Exception('Нет токена авторизации');

  //     final messageApi = GetIt.I<Openapi>().getMessageControllerApi();

  //     // Подготавливаем файлы в формате MultipartFile
  //     final files = await Future.wait(
  //       _selectedFiles.map((file) async {
  //         final fileData = await File(file.path!).readAsBytes();
  //         final fileName = file.path!.split('/').last;
  //         final mimeType =
  //             lookupMimeType(fileName) ?? 'application/octet-stream';

  //         return MultipartFile.fromBytes(
  //           fileData,
  //           filename: fileName,
  //           contentType: MediaType.parse(
  //               mimeType), // Теперь используем правильный MediaType
  //         );
  //       }),
  //     );

  //     final response = await messageApi.createMessage(
  //       chatId: widget.chatId,
  //       text: _messageController.text,
  //       files: files.isNotEmpty ? BuiltList<MultipartFile>(files) : null,
  //       headers: {'Authorization': 'Bearer $token'},
  //     );

  //     if (response.data != null && mounted) {
  //       setState(() {
  //         _messages.insert(0, response.data!);
  //         _messageController.clear();
  //         _selectedFiles.clear();
  //       });
  //       _scrollToBottom();
  //     }
  //   } catch (e) {
  //     debugPrint('Ошибка отправки сообщения: $e');
  //     if (mounted) {
  //       _showErrorSnackbar('Ошибка отправки сообщения: ${e.toString()}');
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isSending = false);
  //     }
  //   }
  // }

  Future<void> _sendMessage() async {
    for (final file in _selectedFiles) {
      if (!File(file.path!).existsSync()) {
        _showErrorSnackbar('Файл ${file.name} не найден');
        return;
      }

      final ext = file.extension?.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        _showErrorSnackbar('Недопустимый тип файла: $ext');
        return;
      }
    }
    if (_messageController.text.isEmpty && _selectedFiles.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) throw Exception('Нет токена авторизации');

      final messageApi = GetIt.I<Openapi>().getMessageControllerApi();
      final formData = FormData();

      // Добавляем текст сообщения
      if (_messageController.text.isNotEmpty) {
        formData.fields.add(MapEntry('text', _messageController.text));
      }

      // Добавляем файлы с правильными MIME-типами
      if (_selectedFiles.isNotEmpty) {
        final files = await Future.wait(_selectedFiles.map((file) async {
          final mimeType = getMediaTypeForFile(file);
          debugPrint(
              'Отправка файла: ${file.name}, тип: ${mimeType?.type}/${mimeType?.subtype}');

          return await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
            contentType: mimeType,
          );
        }));

        formData.files.addAll(files.map((file) => MapEntry('files', file)));
      }

      // Отправляем запрос
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
    } on DioException catch (e) {
      debugPrint('Ошибка отправки сообщения: ${e.response?.data}');
      if (mounted) {
        _showErrorSnackbar(
            'Ошибка отправки сообщения: ${e.response?.data?['error'] ?? e.message}');
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // MessageType _getMessageType(PlatformFile file) {
  //   if (['jpg', 'png'].contains(file.extension)) return MessageType.image;
  //   if (['mp4', 'mov'].contains(file.extension)) return MessageType.video;
  //   return MessageType.file;
  // }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result != null) {
        // Проверяем и логируем информацию о файлах
        for (final file in result.files) {
          final ext = file.extension?.toLowerCase();
          if (!_allowedExtensions.contains(ext)) {
            _showErrorSnackbar('Недопустимый тип файла: $ext');
            return;
          }
          debugPrint(
              'Выбран файл: ${file.name}, расширение: $ext, размер: ${file.size} bytes');
        }

        setState(() => _selectedFiles.addAll(result.files));
      }
    } catch (e) {
      debugPrint('Ошибка при выборе файла: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выборе файла: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImageOrVideo() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedFiles.add(PlatformFile(
            name: image.name,
            size: File(image.path).lengthSync(),
            path: image.path,
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе медиа: ${e.toString()}')),
      );
    }
  }

  // void _showError(String message) {
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text(message)));
  // }

  void _openFullScreen(PlatformFile file) async {
    final fileExt = file.extension?.toLowerCase();

    if (fileExt == 'pdf') {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: SfPdfViewer.file(File(file.path!)),
            ),
          ));
    } else if (['jpg', 'jpeg', 'png'].contains(fileExt)) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(child: Image.file(File(file.path!))),
            ),
          ));
    } else if (['mp4', 'mov'].contains(fileExt)) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(file.name)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, size: 50),
                    const SizedBox(height: 20),
                    Text('Видео файл: ${file.name}'),
                  ],
                ),
              ),
            ),
          ));
    } else {
      try {
        await OpenFile.open(file.path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть файл')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chat?.chatName ?? (widget.isGroup ? 'Группа' : 'Чат')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // body: Column(
      //   children: [
      //     const Divider(height: 1, thickness: 1, color: Colors.grey),
      //     Expanded(child: _buildMessagesList()),
      //     if (_selectedFiles.isNotEmpty) _buildSelectedFilesPreview(),
      //     _buildMessageInput(),
      //   ],
      // ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chat == null
              ? const Center(child: Text('Чат не найден или нет доступа'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageItem(_messages[index]),
                      ),
                    ),
                    if (_selectedFiles.isNotEmpty) _buildSelectedFilesPreview(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showFilePickerOptions(),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Сообщение',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: _isSending
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.send),
                            onPressed: _isSending ? null : _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMessageItem(MessageDTO message) {
    final isMe = message.userId == widget.currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.text != null) Text(message.text!),
            if (message.files != null)
              ...message.files!.map((file) => _buildFilePreview(file)),
            const SizedBox(height: 5),
            Text(
              '${message.createdWhen?.hour}:${message.createdWhen?.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(FileDTO file) {
    final isImage =
        ['jpg', 'jpeg', 'png'].contains(file.fileType?.toLowerCase());
    final isVideo = ['mp4', 'mov'].contains(file.fileType?.toLowerCase());

    return GestureDetector(
      onTap: () => _openFullScreen(PlatformFile(
        name: file.fileName ?? 'file',
        size: 0,
        path: file.fileUrl,
      )),
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        child: isImage
            ? Image.network(file.fileUrl ?? '',
                width: 200, height: 150, fit: BoxFit.cover)
            : isVideo
                ? const Icon(Icons.videocam, size: 50)
                : ListTile(
                    leading: Icon(FileUtils.getFileIcon(file.fileType)),
                    title: Text(file.fileName ?? 'Файл'),
                    subtitle: Text(FileUtils.formatFileSize(0)),
                  ),
      ),
    );
  }

  Widget _buildSelectedFilesPreview() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) =>
            _buildFileThumbnail(_selectedFiles[index], index),
      ),
    );
  }

  Widget _buildFileThumbnail(PlatformFile file, int index) {
    final isImage =
        ['jpg', 'jpeg', 'png'].contains(file.extension?.toLowerCase());

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          child: isImage
              ? Image.file(File(file.path!),
                  width: 80, height: 80, fit: BoxFit.cover)
              : Icon(FileUtils.getFileIcon(file.extension), size: 80),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, size: 15),
            onPressed: () => setState(() => _selectedFiles.removeAt(index)),
          ),
        ),
      ],
    );
  }

  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Файл'),
              onTap: () {
                _pickFiles();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Фото или видео'),
              onTap: () {
                _pickImageOrVideo();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
