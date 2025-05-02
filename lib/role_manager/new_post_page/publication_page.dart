import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PublicationPage extends StatefulWidget {
  final List<File> selectedImages;
  final String text;

  const PublicationPage(
      {super.key, required this.selectedImages, required this.text});

  @override
  // ignore: library_private_types_in_public_api
  _PublicationPageState createState() => _PublicationPageState();
}

class _PublicationPageState extends State<PublicationPage> {
  final List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    } else {
      print('No files selected.');
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
          onPressed: () {
            Navigator.pop(context);
          },
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
                onTap: _pickFiles,
              ),
              ..._selectedFiles.map((file) => ListTile(
                    title: Text(file.name,
                        style: const TextStyle(color: Colors.black)),
                    subtitle: Text(
                        '${(file.size / 1024).toStringAsFixed(2)} KB',
                        style: const TextStyle(color: Colors.grey)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _selectedFiles.remove(file);
                        });
                      },
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
                  onPressed: () {
                    Navigator.pop(context, {
                      'selectedImages': widget.selectedImages,
                      'text': widget.text,
                      'selectedFiles': _selectedFiles,
                      'publish': true,
                    });
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
                  child: const Text('Опубликовать',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
