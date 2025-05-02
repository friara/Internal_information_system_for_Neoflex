import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'publication_page.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isNextButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateNextButtonState);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateNextButtonState);
    _textController.dispose();
    super.dispose();
  }

  void _updateNextButtonState() {
    setState(() {
      _isNextButtonEnabled =
          _textController.text.isNotEmpty || _selectedImages.isNotEmpty;
    });
  }

  Future<void> _pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _pickImageMobile();
    } else {
      await _pickImageDesktop();
    }
  }

  Future<void> _pickImageMobile() async {
    final picker = ImagePicker();
    List<XFile>? pickedFiles;
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
      if (status.isDenied) {
        if (await Permission.photos.shouldShowRequestRationale) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Требуется доступ'),
              content: const Text(
                  'Приложению нужен доступ к галереи для выбора фото'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await openAppSettings();
                  },
                  child: const Text('Настройки'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    try {
      pickedFiles = await picker.pickMultiImage();

      setState(() {
        if (pickedFiles != null) {
          for (var file in pickedFiles) {
            _selectedImages.add(File(file.path));
          }
        } else {
          print('No image selected.');
        }
        _updateNextButtonState();
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: $e')),
      );
    }
  }

  Future<void> _pickImageDesktop() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        _selectedImages.addAll(files);
        _updateNextButtonState();
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 3 / 7;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.purple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Align(
          alignment: Alignment.center,
          child: Text("Новый пост"),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isNextButtonEnabled
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicationPage(
                          selectedImages: _selectedImages,
                          text: _textController.text,
                        ),
                      ),
                    );

                    if (result != null && result.containsKey('publish')) {
                      Navigator.pop(context, result);
                    }
                  }
                : null,
            style: TextButton.styleFrom(
              foregroundColor:
                  _isNextButtonEnabled ? Colors.purple : Colors.grey,
            ),
            child: const Text('Далее'),
          ),
        ],
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Напишите что-нибудь...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 50),
              if (_selectedImages.isNotEmpty)
                Container(
                  height: imageHeight,
                  child: PageView.builder(
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _selectedImages[index],
                            width: screenWidth,
                            height: imageHeight,
                            fit: BoxFit.contain,
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.7),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 35.0, bottom: 16.0),
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: _pickImage,
              child: Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
