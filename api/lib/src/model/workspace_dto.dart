//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:openapi/src/model/booking_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'workspace_dto.g.dart';

/// WorkspaceDTO
///
/// Properties:
/// * [id] 
/// * [workspaceName] 
/// * [currentBookings] 
/// * [available] 
@BuiltValue()
abstract class WorkspaceDTO implements Built<WorkspaceDTO, WorkspaceDTOBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'workspaceName')
  String? get workspaceName;

  @BuiltValueField(wireName: r'currentBookings')
  BuiltList<BookingDTO>? get currentBookings;

  @BuiltValueField(wireName: r'available')
  bool? get available;

  WorkspaceDTO._();

  factory WorkspaceDTO([void updates(WorkspaceDTOBuilder b)]) = _$WorkspaceDTO;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WorkspaceDTOBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WorkspaceDTO> get serializer => _$WorkspaceDTOSerializer();
}

class _$WorkspaceDTOSerializer implements PrimitiveSerializer<WorkspaceDTO> {
  @override
  final Iterable<Type> types = const [WorkspaceDTO, _$WorkspaceDTO];

  @override
  final String wireName = r'WorkspaceDTO';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WorkspaceDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.workspaceName != null) {
      yield r'workspaceName';
      yield serializers.serialize(
        object.workspaceName,
        specifiedType: const FullType(String),
      );
    }
    if (object.currentBookings != null) {
      yield r'currentBookings';
      yield serializers.serialize(
        object.currentBookings,
        specifiedType: const FullType(BuiltList, [FullType(BookingDTO)]),
      );
    }
    if (object.available != null) {
      yield r'available';
      yield serializers.serialize(
        object.available,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WorkspaceDTO object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WorkspaceDTOBuilder result,
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
        case r'workspaceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workspaceName = valueDes;
          break;
        case r'currentBookings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BookingDTO)]),
          ) as BuiltList<BookingDTO>;
          result.currentBookings.replace(valueDes);
          break;
        case r'available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.available = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WorkspaceDTO deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WorkspaceDTOBuilder();
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

