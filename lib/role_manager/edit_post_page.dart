import 'dart:io';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:openapi/openapi.dart';

class EditPostPage extends StatefulWidget {
  final int? postId; // Добавляем параметр postId
  final String initialText;
  final List<String> initialImagePaths;
  final Function(String, List<String>) onSave; // Обновляем сигнатуру onSave
  final Function() onDelete;

  const EditPostPage({
    super.key,
    this.postId,
    required this.initialText,
    required this.initialImagePaths,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _textController;
  late TextEditingController _titleController;
  late List<String> _currentImagePaths;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _currentImagePaths = List.from(widget.initialImagePaths);
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _savePost() async {
    setState(() => _isLoading = true);
    try {
      final postApi = GetIt.I<Openapi>().getPostControllerApi();
      final files = await _convertFilesToMultipart();

      // Логирование перед отправкой
      debugPrint('Saving post with text: ${_textController.text}');
      debugPrint('Files count: ${files.length}');
      for (final file in files) {
        debugPrint('File: ${file.filename}, type: ${file.contentType}');
      }

      if (widget.postId == null) {
        // Создание нового поста
        final response = await postApi.createPost(
          text: _textController.text,
          files: files.isEmpty ? null : files,
        );
        debugPrint('Post created: ${response.data}');
      } else {
        // Обновление существующего поста
        final response = await postApi.updatePost(
          id: widget.postId!,
          postDTO: PostDTO((b) => b..text = _textController.text),
          files: files.isEmpty ? null : files,
        );
        debugPrint('Post updated: ${response.data}');
      }

      widget.onSave(_textController.text, _currentImagePaths);
      if (mounted) Navigator.pop(context);
    } on DioException catch (e) {
      debugPrint('Error saving post: ${e.response?.data}');
      debugPrint('Request: ${e.requestOptions.data}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ошибка сохранения: ${e.response?.data?['details'] ?? e.message}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неизвестная ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<BuiltList<MultipartFile>> _convertFilesToMultipart() async {
    final files = <MultipartFile>[];

    for (final path in _currentImagePaths) {
      if (path.startsWith('http')) continue;

      try {
        final file = File(path);
        if (!await file.exists()) continue;

        // Получаем имя файла из пути
        final fileName = path
            .split(RegExp(r'[\\/]'))
            .last; // Улучшенное извлечение имени файла

        // Определяем MIME-тип с использованием пакета mime
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        debugPrint('File: $fileName, MIME type: $mimeType');

        // Читаем файл как байты
        final fileBytes = await file.readAsBytes();

        // Создаем MultipartFile
        files.add(MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));
      } catch (e) {
        debugPrint('Error processing file $path: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка обработки файла $path')),
          );
        }
      }
    }

    return BuiltList(files);
  }

  // String _getMimeType(String fileName) {
  //   final extension = fileName.split('.').last.toLowerCase();
  //   switch (extension) {
  //     case 'jpg':
  //     case 'jpeg':
  //       return 'image/jpeg';
  //     case 'png':
  //       return 'image/png';
  //     case 'gif':
  //       return 'image/gif';
  //     default:
  //       return 'application/octet-stream';
  //   }
  // }

  Future<void> _addNewImage() async {
    final pickedFiles = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (pickedFiles != null) {
      setState(() {
        _currentImagePaths.addAll(
          pickedFiles.paths.map((path) => path!).toList(),
        );
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пост?'),
        content: const Text('Это действие нельзя отменить'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete();
      Navigator.pop(context);
    }
  }

  Widget _buildImageWidget(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0), // Такие же отступы как в ленте
      child: imagePath.startsWith('assets/')
          ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Редактировать пост'),
        centerTitle: true,
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Введите текст поста...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 50),
              if (_currentImagePaths.isNotEmpty)
                SizedBox(
                  height: 500,
                  child: PageView.builder(
                    itemCount: _currentImagePaths.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildImageWidget(_currentImagePaths[index]),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentImagePaths.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 50),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ElevatedButton(
                  onPressed: _addNewImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.purple),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Добавить изображение',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _textController.text,
                      _currentImagePaths,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Сохранить изменения',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
