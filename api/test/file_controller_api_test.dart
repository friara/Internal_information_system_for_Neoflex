import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for FileControllerApi
void main() {
  final instance = Openapi().getFileControllerApi();

  group(FileControllerApi, () {
    //Future<FileDTO> createFile(FileDTO fileDTO) async
    test('test createFile', () async {
      // TODO
    });

    //Future deleteFile(int id) async
    test('test deleteFile', () async {
      // TODO
    });

    //Future<BuiltList<FileDTO>> getAllFiles() async
    test('test getAllFiles', () async {
      // TODO
    });

    //Future<FileDTO> getFileById(int id) async
    test('test getFileById', () async {
      // TODO
    });

  });
}
