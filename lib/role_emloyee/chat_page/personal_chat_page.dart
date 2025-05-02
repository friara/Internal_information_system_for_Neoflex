import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'message_model.dart';
import 'file_utils.dart';

class PersonalChatPage extends StatefulWidget {
  final String userId;
  final bool isGroup;
  final List<String> groupMembers;
  final File? groupImage;

  const PersonalChatPage({
    super.key,
    required this.userId,
    this.isGroup = false,
    this.groupMembers = const [],
    this.groupImage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PersonalChatPageState createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final List<PlatformFile> _selectedFiles = [];

  void _sendMessage() {
    if (_messageController.text.isEmpty && _selectedFiles.isEmpty) return;

    setState(() {
      if (_messageController.text.isNotEmpty) {
        _messages.add(Message(
          type: MessageType.text,
          text: _messageController.text,
          sender: 'Я',
          time: DateTime.now(),
        ));
      }

      for (var file in _selectedFiles) {
        _messages.add(Message(
          type: _getMessageType(file),
          file: file,
          sender: 'Я',
          time: DateTime.now(),
        ));
      }

      _messageController.clear();
      _selectedFiles.clear();
    });
  }

  MessageType _getMessageType(PlatformFile file) {
    if (['jpg', 'png'].contains(file.extension)) return MessageType.image;
    if (['mp4', 'mov'].contains(file.extension)) return MessageType.video;
    return MessageType.file;
  }

  Future<void> _pickFiles() async {
    try {
      if (Platform.isMacOS) {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.any,
        );
        if (result != null) {
          setState(() => _selectedFiles.addAll(result.files));
        }
      } else {
        final result = await FilePicker.platform.pickFiles(allowMultiple: true);
        if (result != null) {
          setState(() => _selectedFiles.addAll(result.files));
        }
      }
    } catch (e) {
      _showError('Ошибка при выборе файла: ${e.toString()}');
    }
  }

  Future<void> _pickImageOrVideo() async {
    try {
      if (Platform.isMacOS) {
        // Для macOS используем file_picker с явным указанием типа
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.media,
        );
        if (result != null) {
          setState(() => _selectedFiles.addAll(result.files));
        }
      } else if (Platform.isIOS) {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _selectedFiles.add(PlatformFile(
              name: image.name,
              size: File(image.path).lengthSync(),
              path: image.path,
            ));
          });
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'mp4', 'mov'],
        );
        if (result != null) {
          setState(() => _selectedFiles.addAll(result.files));
        }
      }
    } catch (e) {
      _showError('Ошибка при выборе медиа: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          Expanded(child: _buildMessagesList()),
          if (_selectedFiles.isNotEmpty) _buildSelectedFilesPreview(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
      automaticallyImplyLeading: false,
      title: InkWell(
        onTap: widget.isGroup ? _showGroupInfo : null,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            if (widget.isGroup) _buildGroupAvatar(),
            const SizedBox(width: 8),
            Text(widget.userId, style: const TextStyle(color: Colors.black)),
            if (widget.isGroup)
              const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey[200],
      backgroundImage:
          widget.groupImage != null ? FileImage(widget.groupImage!) : null,
      child:
          widget.groupImage == null ? const Icon(Icons.group, size: 16) : null,
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
    );
  }

  Widget _buildMessageItem(Message message) {
    return Align(
      alignment:
          message.sender == 'Я' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: message.sender == 'Я' ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: message.sender == 'Я'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            _buildMessageContent(message),
            const SizedBox(height: 5),
            Text(
              '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    switch (message.type) {
      case MessageType.text:
        return Text(message.text!);
      case MessageType.image:
        return _buildMediaPreview(message.file!, Icons.image);
      case MessageType.video:
        return _buildMediaPreview(message.file!, Icons.videocam);
      case MessageType.file:
        return _buildFilePreview(message.file!);
    }
  }

  Widget _buildMediaPreview(PlatformFile file, IconData icon) {
    return GestureDetector(
      onTap: () => _openFullScreen(file),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: file.extension == 'jpg' || file.extension == 'png'
            ? Image.file(File(file.path!), fit: BoxFit.cover)
            : Icon(icon, size: 50),
      ),
    );
  }

  Widget _buildFilePreview(PlatformFile file) {
    return GestureDetector(
      onTap: () => _openFullScreen(file),
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
                Icon(FileUtils.getFileIcon(file.extension)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              FileUtils.formatFileSize(file.size),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
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
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          child: file.extension == 'jpg' || file.extension == 'png'
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

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40.0),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                // suffixIcon: IconButton(
                //   icon: const Icon(Icons.emoji_emotions),
                //   onPressed: () => _showEmojiPicker(),
                // ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.groupImage != null)
              CircleAvatar(
                  radius: 50, backgroundImage: FileImage(widget.groupImage!)),
            const SizedBox(height: 16),
            Text(widget.userId,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Участники:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.groupMembers.map((member) => ListTile(
                  leading: const CircleAvatar(
                      backgroundImage:
                          AssetImage("assets/images/imageMyProfile.jpg")),
                  title: Text(member),
                )),
          ],
        ),
      ),
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
        _showError('Не удалось открыть файл');
      }
    }
  }
}
