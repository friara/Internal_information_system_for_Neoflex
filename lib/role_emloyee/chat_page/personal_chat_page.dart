import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_feed_neoflex/role_emloyee/chat_page/attached_personal_chat_page.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PersonalChatPage extends StatefulWidget {
  const PersonalChatPage({
    Key? key,
    required this.userId,
    this.isGroup = false,
    this.groupMembers = const [],
    this.groupImage,
  }) : super(key: key);

  final String userId;
  final bool isGroup;
  final List<String> groupMembers;
  final File? groupImage;

  @override
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final List<PlatformFile> _selectedFiles = [];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty || _selectedFiles.isNotEmpty) {
      setState(() {
        // Добавляем текстовое сообщение
        if (_messageController.text.isNotEmpty) {
          messages.add(Message(
            type: MessageType.text,
            text: _messageController.text,
            sender: 'Я',
            time: DateTime.now(),
          ));
        }

        // Добавляем файлы как отдельные сообщения
        for (var file in _selectedFiles) {
          messages.add(Message(
            type: file.extension == 'jpg' || file.extension == 'png'
                ? MessageType.image
                : file.extension == 'mp4' || file.extension == 'mov'
                    ? MessageType.video
                    : MessageType.file,
            file: file,
            sender: 'Я',
            time: DateTime.now(),
          ));
        }

        _messageController.clear();
        _selectedFiles.clear();
      });
    }
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: GridView.count(
            crossAxisCount: 5,
            children: List.generate(20, (index) {
              return IconButton(
                icon: const Text('😊'),
                onPressed: () {
                  _messageController.text += '😊';
                  Navigator.pop(context);
                },
              );
            }),
          ),
        );
      },
    );
  }

  // Метод для выбора файлов
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any, // Разрешить выбор любого файла
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      print("Ошибка при выборе файла: $e");
    }
  }

  // Метод для выбора фото или видео
  Future<void> _pickImageOrVideo() async {
    try {
      if (kIsWeb ||
          Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS) {
        // Логика для ПК
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: [
            // Растровые изображения
            'bmp', 'gif', 'hdr', 'jpeg', 'jpg', 'jpe', 'jp2', 'png', 'psd',
            'raw', 'tga', 'tiff', 'tif', 'wdp', 'hdp', 'xpm',
            // Видео
            '3gp', 'aaf', 'asf', 'avi', 'bik', 'cpk', 'flv', 'mkv', 'mov',
            'mpeg', 'mxf', 'nut', 'nsv', 'ogg', 'ogm', 'qt',
          ],
        );

        if (result != null) {
          setState(() {
            _selectedFiles.addAll(result.files);
          });
        }
      } else {
        // Логика для мобильных устройств
        final ImagePicker _picker = ImagePicker();
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          final file = File(image.path);
          final fileSize = await file.length(); // Получаем размер файла
          setState(() {
            _selectedFiles.add(PlatformFile(
              name: image.name,
              size: fileSize,
              path: image.path,
            ));
          });
        }
      }
    } catch (e) {
      print("Ошибка при выборе фото или видео: $e");
    }
  }

  // Метод для отображения выбора (Файл или Фото/Видео)
  void _showFilePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
        );
      },
    );
  }

  // Метод для открытия файла, фото или видео в полноэкранном режиме
  void _openFullScreen(BuildContext context, PlatformFile file) async {
    final fileExt = file.extension?.toLowerCase();

    if (fileExt == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: SfPdfViewer.file(File(file.path!)),
          ),
        ),
      );
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExt)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: Center(child: Image.file(File(file.path!))),
          ),
        ),
      );
    } else if (['mp4', 'mov', 'avi', 'mkv', 'flv', 'webm'].contains(fileExt)) {
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
        ),
      );
    } else if (['txt', 'csv', 'json', 'xml', 'log'].contains(fileExt)) {
      // Открываем текстовые файлы с возможностью просмотра содержимого
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FutureBuilder<String>(
            future: File(file.path!).readAsString(),
            builder: (context, snapshot) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(file.name),
                ),
                body: snapshot.hasData
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(snapshot.data!),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      );
    } else if (['docx', 'doc', 'xls', 'xlsx'].contains(fileExt)) {
      // Открытие документов Word и Excel через системное приложение
      try {
        final fileToOpen = File(file.path!);
        await OpenFile.open(fileToOpen.path);
      } catch (e) {
        print('Ошибка при открытии файла $fileExt: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть файл ${file.name}')),
        );
      }
    } else {
      // Общий случай для других типов файлов
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(file.name)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getFileIcon(fileExt), size: 50),
                  const SizedBox(height: 20),
                  Text(file.name),
                  const SizedBox(height: 10),
                  Text('Размер: ${_formatFileSize(file.size)}'),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

// Вспомогательная функция для получения иконки по типу файла
  IconData _getFileIcon(String? fileExt) {
    switch (fileExt) {
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'ogg':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

// Вспомогательная функция для форматирования размера файла
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         AttachedPersonalChatPage(userId: widget.userId),
            //   ),
            // );
            if (widget.isGroup) {
              // Показать информацию о группе
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.groupImage != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(widget.groupImage!),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.userId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Участники:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...widget.groupMembers.map((member) => ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/imageMyProfile.jpg"),
                            ),
                            title: Text(member),
                          )),
                    ],
                  ),
                ),
              );
            }
          },
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              if (widget.isGroup)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: widget.groupImage != null
                      ? FileImage(widget.groupImage!)
                      : null,
                  child: widget.groupImage == null
                      ? const Icon(Icons.group, size: 16, color: Colors.grey)
                      : null,
                ),
              const SizedBox(width: 8),
              Text(
                widget.userId,
                style: const TextStyle(color: Colors.black),
              ),
              if (widget.isGroup)
                const Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.sender == 'Я'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.sender == 'Я'
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: message.sender == 'Я'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.type == MessageType.text &&
                            message.text != null)
                          Text(message.text!),
                        if (message.type == MessageType.image)
                          GestureDetector(
                            onTap: () =>
                                _openFullScreen(context, message.file!),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.file(
                                File(message.file!.path!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (message.type == MessageType.video)
                          GestureDetector(
                            onTap: () =>
                                _openFullScreen(context, message.file!),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: const Icon(Icons.videocam, size: 50),
                            ),
                          ),
                        if (message.type == MessageType.file)
                          GestureDetector(
                            onTap: () =>
                                _openFullScreen(context, message.file!),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getFileIcon(
                                          message.file!.extension)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          message.file!.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatFileSize(message.file!.size),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedFiles.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = _selectedFiles[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        child:
                            file.extension == 'jpg' || file.extension == 'png'
                                ? Image.file(
                                    File(file.path!),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    _getFileIcon(file.extension),
                                    size: 80,
                                  ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 15),
                          onPressed: () {
                            setState(() {
                              _selectedFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 40.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showFilePickerOptions(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Сообщение',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions),
                        onPressed: () => _showEmojiPicker(context),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum MessageType { text, image, video, file }

class Message {
  final MessageType type;
  final String? text;
  final PlatformFile? file;
  final String sender;
  final DateTime time;

  Message({
    required this.type,
    this.text,
    this.file,
    required this.sender,
    required this.time,
  });
}
