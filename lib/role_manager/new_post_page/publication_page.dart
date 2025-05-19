import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:openapi/src/api/post_controller_api.dart';
import 'package:openapi/src/model/post_dto.dart';
import 'package:built_collection/built_collection.dart';
import 'package:openapi/openapi.dart'; // Добавляем импорт для serializers

class PublicationPage extends StatefulWidget {
  final List<File> selectedImages;
  final String text;

  const PublicationPage({
    super.key,
    required this.selectedImages,
    required this.text,
  });

  @override
  _PublicationPageState createState() => _PublicationPageState();
}

class _PublicationPageState extends State<PublicationPage> {
  final List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeDio(); // Инициализируем Dio при создании
  }

  Future<void> _initializeDio() async {
    // Получаем токен из AuthRepositoryImpl
    final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();

    // Настраиваем Dio
    _dio.options.baseUrl = 'http://localhost:8080'; // Базовый URL
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  Future<void> _publishPost() async {
    setState(() => _isLoading = true);

    try {
      // Используем настроенный Dio
      final postApi = PostControllerApi(_dio, Openapi().serializers);
      final files = await _convertFilesToMultipart();

      final response = await postApi.createPost(
        text: widget.text,
        files: files,
      );

      if (mounted) {
        Navigator.pop(context, {
          'success': true,
          'post': response.data,
        });
      }
    } catch (e) {
      // Обработка ошибок
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<BuiltList<MultipartFile>> _convertFilesToMultipart() async {
    final files = <MultipartFile>[];

    for (final image in widget.selectedImages) {
      final file = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );
      files.add(file);
    }

    for (final platformFile in _selectedFiles) {
      final file = await MultipartFile.fromFile(
        platformFile.path!,
        filename: platformFile.name,
      );
      files.add(file);
    }

    return BuiltList<MultipartFile>(
        files); // Создаем BuiltList напрямую из списка
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.center,
          child: Text("Публикация"),
        ),
        centerTitle: true,
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const SizedBox(height: 50),
              if (widget.selectedImages.isNotEmpty)
                Container(
                  height: imageHeight,
                  child: PageView.builder(
                    itemCount: widget.selectedImages.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        widget.selectedImages[index],
                        width: screenWidth,
                        height: imageHeight,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.file_present_outlined, color: Colors.grey),
                title:
                    const Text('Файл', style: TextStyle(color: Colors.black)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: _isLoading ? null : _pickFiles,
              ),
              ..._selectedFiles.map((file) => ListTile(
                    title: Text(file.name,
                        style: const TextStyle(color: Colors.black)),
                    subtitle: Text(
                      '${(file.size / 1024).toStringAsFixed(2)} KB',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _selectedFiles.remove(file)),
                    ),
                  )),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            bottom: 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _publishPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Опубликовать',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
