import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for TestControllerApi
void main() {
  final instance = Openapi().getTestControllerApi();

  group(TestControllerApi, () {
    //Future<String> privateHello() async
    test('test privateHello', () async {
      // TODO
    });

    //Future<String> publicHello() async
    test('test publicHello', () async {
      // TODO
    });

  });
}
