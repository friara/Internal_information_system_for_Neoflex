import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for NotificationControllerApi
void main() {
  final instance = Openapi().getNotificationControllerApi();

  group(NotificationControllerApi, () {
    //Future<BuiltList<MessageNotification>> getNotifications({ int limit }) async
    test('test getNotifications', () async {
      // TODO
    });

    //Future<int> getNotificationsCount() async
    test('test getNotificationsCount', () async {
      // TODO
    });

    //Future markAllAsRead() async
    test('test markAllAsRead', () async {
      // TODO
    });

    //Future markAsRead(int id) async
    test('test markAsRead', () async {
      // TODO
    });

    //Future markAsReadForChat(int id) async
    test('test markAsReadForChat', () async {
      // TODO
    });

  });
}
