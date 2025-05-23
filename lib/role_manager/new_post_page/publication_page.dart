import 'dart:io';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:openapi/openapi.dart';
import 'package:path/path.dart' as p;
import 'package:built_collection/built_collection.dart';

class PublicationPage extends StatefulWidget {
  const PublicationPage({super.key});

  @override
  _PublicationPageState createState() => _PublicationPageState();
}

class _PublicationPageState extends State<PublicationPage> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  bool _isNextButtonEnabled = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateNextButtonState);
    _initializeDio();
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

  Future<void> _initializeDio() async {
    final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
    _dio.options.baseUrl = 'http://localhost:8080';
    _dio.options.headers['Authorization'] = 'Bearer $token';
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

  Future<void> _publishPost() async {
    setState(() => _isLoading = true);

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) {
        throw Exception('No access token');
      }

      final postApi = GetIt.I<Openapi>().getPostControllerApi();
      final files = await _convertFilesToMultipart();

      debugPrint('Sending post with text: ${_textController.text}');
      debugPrint('Files count: ${files.length}');

      final response = await postApi.createPost(
        text: _textController.text,
        files: files.isEmpty ? null : files,
      );

      debugPrint('Post created successfully: ${response.data}');

      if (mounted) {
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   AppRoutes.newsFeed,
        //   (route) => false,
        //   arguments: {'postCreated': true}, // Передаем флаг успешного создания
        // );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      debugPrint('DioError: ${e.message}');
      debugPrint('Response: ${e.response?.data}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Ошибка публикации: ${e.response?.data?['details'] ?? e.message}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Неизвестная ошибка: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<BuiltList<MultipartFile>> _convertFilesToMultipart() async {
    final files = <MultipartFile>[];

    for (final file in _selectedImages) {
      if (!await file.exists()) continue;

      try {
        final fileName = p.basename(file.path);
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

        debugPrint('File: $fileName, MIME type: $mimeType');

        final fileBytes = await file.readAsBytes();

        files.add(MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));
      } catch (e) {
        debugPrint('Error processing file ${file.path}: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка обработки файла ${file.path}')),
          );
        }
      }
    }

    return BuiltList(files);
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Align(
          alignment: Alignment.center,
          child: Text("Новый пост"),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed:
                _isNextButtonEnabled && !_isLoading ? _publishPost : null,
            style: TextButton.styleFrom(
              foregroundColor: _isNextButtonEnabled && !_isLoading
                  ? Colors.purple
                  : Colors.grey,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.purple,
                    ),
                  )
                : const Text('Опубликовать'),
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
              const SizedBox(height: 50),
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
              const SizedBox(height: 100),
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

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/services.dart';
// import 'package:get_it/get_it.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';
// import 'package:news_feed_neoflex/app_routes.dart';
// import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
// import 'package:openapi/src/api/post_controller_api.dart';
// import 'package:openapi/src/model/post_dto.dart';
// import 'package:built_collection/built_collection.dart';
// import 'package:openapi/openapi.dart'; // Добавляем импорт для serializers
// import 'package:path/path.dart' as p;

// class PublicationPage extends StatefulWidget {
//   final List<File> selectedImages;
//   final String text;

//   const PublicationPage({
//     super.key,
//     required this.selectedImages,
//     required this.text,
//   });

//   @override
//   _PublicationPageState createState() => _PublicationPageState();
// }

// class _PublicationPageState extends State<PublicationPage> {
//   final List<PlatformFile> _selectedFiles = [];
//   bool _isLoading = false;
//   List<String> _currentImagePaths = [];
//   final Dio _dio = Dio();

//   @override
//   void initState() {
//     super.initState();
//     _currentImagePaths =
//         widget.selectedImages.map((file) => file.path).toList();
//     _initializeDio(); // Инициализируем Dio при создании
//   }

//   Future<void> _initializeDio() async {
//     // Получаем токен из AuthRepositoryImpl
//     final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();

//     // Настраиваем Dio
//     _dio.options.baseUrl = 'http://localhost:8080'; // Базовый URL
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   Future<void> _pickFiles() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//     );

//     if (result != null) {
//       setState(() {
//         _selectedFiles.addAll(result.files);
//         _currentImagePaths.addAll(result.files.map((f) => f.path!).toList());
//       });
//     }
//   }

//   Future<void> _publishPost() async {
//     setState(() => _isLoading = true);

//     try {
//       final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
//       if (token == null) {
//         throw Exception('No access token');
//       }

//       final postApi = GetIt.I<Openapi>().getPostControllerApi();
//       final files = await _convertFilesToMultipart();

//       // Логирование перед отправкой
//       debugPrint('Sending post with text: ${widget.text}');
//       debugPrint('Files count: ${files.length}');
//       for (final file in files) {
//         debugPrint('File: ${file.filename}, type: ${file.contentType}');
//       }

//       final response = await postApi.createPost(
//         text: widget.text,
//         files: files.isEmpty ? null : files, // Отправляем null если файлов нет
//       );

//       debugPrint('Post created successfully: ${response.data}');

//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           AppRoutes.newsFeed,
//           (route) => false,
//         );
//       }
//     } on DioException catch (e) {
//       debugPrint('DioError: ${e.message}');
//       debugPrint('Response: ${e.response?.data}');
//       debugPrint('Headers: ${e.response?.headers}');
//       debugPrint('Request: ${e.requestOptions.data}');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//                 'Ошибка публикации: ${e.response?.data?['details'] ?? e.message}'),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Неизвестная ошибка: $e')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<BuiltList<MultipartFile>> _convertFilesToMultipart() async {
//     final files = <MultipartFile>[];

//     for (final path in _currentImagePaths) {
//       if (path.startsWith('http')) continue;

//       try {
//         final file = File(path);
//         if (!await file.exists()) continue;

//         debugPrint('Processing file path: $path');

//         // final fileName = path
//         //     .split('/')
//         //     .last; // Используем '/' вместо Platform.pathSeparator для совместимости
//         final fileName = p.basename(file.path);
//         final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

//         debugPrint('File: $fileName, MIME type: $mimeType');

//         final fileBytes = await file.readAsBytes();

//         files.add(MultipartFile.fromBytes(
//           fileBytes,
//           filename: fileName,
//           contentType: MediaType.parse(mimeType),
//         ));
//       } catch (e) {
//         debugPrint('Error processing file $path: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Ошибка обработки файла $path')),
//           );
//         }
//       }
//     }

//     return BuiltList(files);
//   }

//   // String _getMimeType(String path) {
//   //   final extension = path.split('.').last.toLowerCase();
//   //   switch (extension) {
//   //     case 'jpg':
//   //     case 'jpeg':
//   //       return 'image/jpeg'; // Изменено с image/jpg на image/jpeg
//   //     case 'png':
//   //       return 'image/png';
//   //     case 'gif':
//   //       return 'image/gif';
//   //     default:
//   //       return 'application/octet-stream';
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final imageHeight = screenWidth * 3 / 7;

//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.purple,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
//           onPressed: _isLoading ? null : () => Navigator.pop(context),
//         ),
//         title: const Align(
//           alignment: Alignment.center,
//           child: Text("Публикация"),
//         ),
//         centerTitle: true,
//         surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
//       ),
//       body: Stack(
//         children: [
//           ListView(
//             padding: const EdgeInsets.only(bottom: 80),
//             children: [
//               const SizedBox(height: 50),
//               if (widget.selectedImages.isNotEmpty)
//                 Container(
//                   height: imageHeight,
//                   child: PageView.builder(
//                     itemCount: widget.selectedImages.length,
//                     itemBuilder: (context, index) {
//                       return Image.file(
//                         widget.selectedImages[index],
//                         width: screenWidth,
//                         height: imageHeight,
//                         fit: BoxFit.contain,
//                       );
//                     },
//                   ),
//                 ),
//               const SizedBox(height: 50),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   widget.text,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               ListTile(
//                 leading:
//                     const Icon(Icons.file_present_outlined, color: Colors.grey),
//                 title:
//                     const Text('Файл', style: TextStyle(color: Colors.black)),
//                 trailing:
//                     const Icon(Icons.arrow_forward_ios, color: Colors.grey),
//                 onTap: _isLoading ? null : _pickFiles,
//               ),
//               ..._selectedFiles.map((file) => ListTile(
//                     title: Text(file.name,
//                         style: const TextStyle(color: Colors.black)),
//                     subtitle: Text(
//                       '${(file.size / 1024).toStringAsFixed(2)} KB',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.close, color: Colors.grey),
//                       onPressed: _isLoading
//                           ? null
//                           : () => setState(() => _selectedFiles.remove(file)),
//                     ),
//                   )),
//               const SizedBox(height: 100),
//             ],
//           ),
//           Positioned(
//             bottom: 20,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width - 40,
//               child: Align(
//                 alignment: Alignment.center,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _publishPost,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text(
//                           'Опубликовать',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
