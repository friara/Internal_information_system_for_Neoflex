//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_chat_name_request.g.dart';

/// UpdateChatNameRequest
///
/// Properties:
/// * [newName] 
@BuiltValue()
abstract class UpdateChatNameRequest implements Built<UpdateChatNameRequest, UpdateChatNameRequestBuilder> {
  @BuiltValueField(wireName: r'newName')
  String get newName;

  UpdateChatNameRequest._();

  factory UpdateChatNameRequest([void updates(UpdateChatNameRequestBuilder b)]) = _$UpdateChatNameRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateChatNameRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateChatNameRequest> get serializer => _$UpdateChatNameRequestSerializer();
}

class _$UpdateChatNameRequestSerializer implements PrimitiveSerializer<UpdateChatNameRequest> {
  @override
  final Iterable<Type> types = const [UpdateChatNameRequest, _$UpdateChatNameRequest];

  @override
  final String wireName = r'UpdateChatNameRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateChatNameRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'newName';
    yield serializers.serialize(
      object.newName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateChatNameRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateChatNameRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'newName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateChatNameRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateChatNameRequestBuilder();
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

