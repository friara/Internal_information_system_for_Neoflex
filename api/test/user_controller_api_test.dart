import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for UserControllerApi
void main() {
  final instance = Openapi().getUserControllerApi();

  group(UserControllerApi, () {
    //Future<UserDTO> createUser(UserDTO userDTO) async
    test('test createUser', () async {
      // TODO
    });

    //Future deleteUser(int id) async
    test('test deleteUser', () async {
      // TODO
    });

    //Future<BuiltList<UserDTO>> getAllUsers() async
    test('test getAllUsers', () async {
      // TODO
    });

    //Future<UserDTO> getUserById(int id) async
    test('test getUserById', () async {
      // TODO
    });

    //Future<UserDTO> updateUser(int id, UserDTO userDTO) async
    test('test updateUser', () async {
      // TODO
    });

    //Future<String> uploadAvatar(int id, { UploadAvatarRequest uploadAvatarRequest }) async
    test('test uploadAvatar', () async {
      // TODO
    });

  });
}
