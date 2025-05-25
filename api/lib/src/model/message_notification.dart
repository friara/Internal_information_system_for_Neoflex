//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_notification.g.dart';

/// Message notification details
///
/// Properties:
/// * [id] - Unique identifier
/// * [sender] - Sender id
/// * [content] - Message content
/// * [timestamp] - Timestamp of the message
/// * [chatId] - Chat id
@BuiltValue()
abstract class MessageNotification implements Built<MessageNotification, MessageNotificationBuilder> {
  /// Unique identifier
  @BuiltValueField(wireName: r'id')
  int? get id;

  /// Sender id
  @BuiltValueField(wireName: r'sender')
  int? get sender;

  /// Message content
  @BuiltValueField(wireName: r'content')
  String? get content;

  /// Timestamp of the message
  @BuiltValueField(wireName: r'timestamp')
  DateTime? get timestamp;

  /// Chat id
  @BuiltValueField(wireName: r'chatId')
  int? get chatId;

  MessageNotification._();

  factory MessageNotification([void updates(MessageNotificationBuilder b)]) = _$MessageNotification;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageNotificationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessageNotification> get serializer => _$MessageNotificationSerializer();
}

class _$MessageNotificationSerializer implements PrimitiveSerializer<MessageNotification> {
  @override
  final Iterable<Type> types = const [MessageNotification, _$MessageNotification];

  @override
  final String wireName = r'MessageNotification';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessageNotification object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.sender != null) {
      yield r'sender';
      yield serializers.serialize(
        object.sender,
        specifiedType: const FullType(int),
      );
    }
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.timestamp != null) {
      yield r'timestamp';
      yield serializers.serialize(
        object.timestamp,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.chatId != null) {
      yield r'chatId';
      yield serializers.serialize(
        object.chatId,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MessageNotification object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessageNotificationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'sender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sender = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.timestamp = valueDes;
          break;
        case r'chatId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.chatId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessageNotification deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageNotificationBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

