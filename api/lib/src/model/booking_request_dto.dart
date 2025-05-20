//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'booking_request_dto.g.dart';

/// BookingRequestDTO
///
/// Properties:
/// * [workspaceId] 
/// * [bookingStart] 
/// * [bookingEnd] 
@BuiltValue()
abstract class BookingRequestDTO implements Built<BookingRequestDTO, BookingRequestDTOBuilder> {
  @BuiltValueField(wireName: r'workspaceId')
  int get workspaceId;

  @BuiltValueField(wireName: r'bookingStart')
  DateTime get bookingStart;

  @BuiltValueField(wireName: r'bookingEnd')
  DateTime get bookingEnd;

  BookingRequestDTO._();

  factory BookingRequestDTO([void updates(BookingRequestDTOBuilder b)]) = _$BookingRequestDTO;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BookingRequestDTOBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BookingRequestDTO> get serializer => _$BookingRequestDTOSerializer();
}

class _$BookingRequestDTOSerializer implements PrimitiveSerializer<BookingRequestDTO> {
  @override
  final Iterable<Type> types = const [BookingRequestDTO, _$BookingRequestDTO];

  @override
  final String wireName = r'BookingRequestDTO';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BookingRequestDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'workspaceId';
    yield serializers.serialize(
      object.workspaceId,
      specifiedType: const FullType(int),
    );
    yield r'bookingStart';
    yield serializers.serialize(
      object.bookingStart,
      specifiedType: const FullType(DateTime),
    );
    yield r'bookingEnd';
    yield serializers.serialize(
      object.bookingEnd,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BookingRequestDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BookingRequestDTOBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'workspaceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.workspaceId = valueDes;
          break;
        case r'bookingStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.bookingStart = valueDes;
          break;
        case r'bookingEnd':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.bookingEnd = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BookingRequestDTO deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BookingRequestDTOBuilder();
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

