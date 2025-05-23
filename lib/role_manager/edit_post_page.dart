import 'dart:io';
import 'package:built_collection/built_collection.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:openapi/openapi.dart';
import 'package:path/path.dart' as p;

class EditPostPage extends StatefulWidget {
  final int? postId; // Добавляем параметр postId
  final String initialText;
  final List<String> initialImagePaths;
  final Function(String, List<String>, bool isSuccess) onSave;
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
    super.dispose();
  }

  Future<void> _savePost() async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);
    try {
      final postApi = GetIt.I<Openapi>().getPostControllerApi();
      final multipartFiles = await _convertFilesToMultipart();

      final response = widget.postId == null
          ? await postApi.createPost(
              text: _textController.text,
              files: multipartFiles.isEmpty ? null : multipartFiles,
            )
          : await postApi.updatePost(
              id: widget.postId!,
              text: _textController.text,
              isMediaUpdated: _currentImagePaths.length !=
                      widget.initialImagePaths.length ||
                  !_checkIfImagesSame(),
              files: multipartFiles,
            );

      // Вызываем onSave и передаем флаг успешного сохранения
      widget.onSave(_textController.text, _currentImagePaths, true);

      // Закрываем экран без показа SnackBar здесь
      if (mounted) Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('Error saving post: $e\n$stackTrace');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${e.toString()}')),
        );
      }
      // Передаем флаг неудачи
      widget.onSave(_textController.text, _currentImagePaths, false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<BuiltList<MultipartFile>> _convertFilesToMultipart() async {
    final files = <MultipartFile>[];

    for (final path in _currentImagePaths) {
      try {
        // Для URL изображений - загружаем их с сервера
        if (path.startsWith('http') || path.startsWith('/')) {
          debugPrint('Processing URL path: $path');

          final dio = GetIt.I<Dio>();
          final response = await dio.get(
            path.startsWith('/') ? '${dio.options.baseUrl}$path' : path,
            options: Options(responseType: ResponseType.bytes),
          );

          final fileName = path.split('/').last;
          final mimeType =
              lookupMimeType(fileName) ?? 'application/octet-stream';

          files.add(MultipartFile.fromBytes(
            response.data as List<int>,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ));
          continue;
        }

        // Для локальных файлов
        debugPrint('Processing local file: $path');
        final file = File(path);
        if (!await file.exists()) {
          debugPrint('File does not exist: $path');
          continue;
        }

        final fileName = p.basename(file.path);
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        final fileBytes = await file.readAsBytes();

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

    debugPrint('Total files prepared for upload: ${files.length}');
    return BuiltList(files);
  }

  bool _checkIfImagesSame() {
    if (_currentImagePaths.length != widget.initialImagePaths.length) {
      return false;
    }

    for (int i = 0; i < _currentImagePaths.length; i++) {
      if (_currentImagePaths[i] != widget.initialImagePaths[i]) {
        return false;
      }
    }

    return true;
  }

  Future<void> _addNewImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      debugPrint('Selected new files:');
      for (final file in result.files) {
        debugPrint(' - ${file.path} (${file.size} bytes)');
      }

      setState(() {
        _currentImagePaths.addAll(
            result.files.map((f) => f.path!).where((p) => p != null).toList());
      });

      debugPrint('Total images now: $_currentImagePaths');
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
      setState(() => _isLoading = true);
      try {
        await widget.onDelete();
        if (mounted) {
          Navigator.pop(context, true); // Возвращаем результат
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildImageWidget(String imagePath) {
    // Для URL изображений (начинающихся с http или /)
    if (imagePath.startsWith('http') || imagePath.startsWith('/')) {
      return FutureBuilder<String?>(
        future: GetIt.I<AuthRepositoryImpl>().getAccessToken(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final token = snapshot.data;
          String fullUrl = imagePath;

          // Если путь начинается с /, добавляем базовый URL
          if (imagePath.startsWith('/')) {
            final dio = GetIt.I<Dio>();
            String baseUrl = dio.options.baseUrl;
            if (!baseUrl.endsWith('/')) baseUrl += '/';
            fullUrl = baseUrl + imagePath.substring(1);
          }

          debugPrint('Loading image from: $fullUrl');
          debugPrint('Using token: ${token != null ? 'present' : 'missing'}');

          return CachedNetworkImage(
            imageUrl: fullUrl,
            fit: BoxFit.cover,
            httpHeaders: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) {
              debugPrint('Error loading image: $error');
              debugPrint('URL: $url');
              if (error is DioException) {
                debugPrint('Status code: ${error.response?.statusCode}');
              }
              return _buildErrorWidget();
            },
          );
        },
      );
    }
    // Для локальных файлов
    else {
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading file: $error');
              return _buildErrorWidget();
            },
          );
        } else {
          debugPrint('File does not exist: $imagePath');
          return _buildErrorWidget();
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
        return _buildErrorWidget();
      }
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Text(
            'Ошибка загрузки изображения',
            style: TextStyle(color: Colors.red[700]),
          ),
        ],
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: _buildImageWidget(_currentImagePaths[index]),
                          ),
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
                  onPressed: _savePost,
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
