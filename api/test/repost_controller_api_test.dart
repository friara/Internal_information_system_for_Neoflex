import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for RepostControllerApi
void main() {
  final instance = Openapi().getRepostControllerApi();

  group(RepostControllerApi, () {
    //Future<RepostDTO> createRepost(int postId, RepostDTO repostDTO) async
    test('test createRepost', () async {
      // TODO
    });

    //Future deleteRepost(int postId, int id) async
    test('test deleteRepost', () async {
      // TODO
    });

    //Future<RepostDTO> getRepostById(int postId, int id) async
    test('test getRepostById', () async {
      // TODO
    });

    //Future<BuiltList<RepostDTO>> getRepostsByPost(int postId) async
    test('test getRepostsByPost', () async {
      // TODO
    });

  });
}
