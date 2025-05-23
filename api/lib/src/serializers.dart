//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/booking_dto.dart';
import 'package:openapi/src/model/booking_request_dto.dart';
import 'package:openapi/src/model/chat_dto.dart';
import 'package:openapi/src/model/chat_summary_dto.dart';
import 'package:openapi/src/model/comment_dto.dart';
import 'package:openapi/src/model/file_dto.dart';
import 'package:openapi/src/model/like_dto.dart';
import 'package:openapi/src/model/media_dto.dart';
import 'package:openapi/src/model/message_dto.dart';
import 'package:openapi/src/model/message_notification_dto.dart';
import 'package:openapi/src/model/page_booking_dto.dart';
import 'package:openapi/src/model/page_chat_summary_dto.dart';
import 'package:openapi/src/model/page_like_dto.dart';
import 'package:openapi/src/model/page_message_dto.dart';
import 'package:openapi/src/model/page_post_response_dto.dart';
import 'package:openapi/src/model/page_user_dto.dart';
import 'package:openapi/src/model/pageable.dart';
import 'package:openapi/src/model/pageable_object.dart';
import 'package:openapi/src/model/post_dto.dart';
import 'package:openapi/src/model/post_response_dto.dart';
import 'package:openapi/src/model/sort_object.dart';
import 'package:openapi/src/model/user_dto.dart';
import 'package:openapi/src/model/user_extended_dto.dart';
import 'package:openapi/src/model/workspace_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  BookingDTO,
  BookingRequestDTO,
  ChatDTO,
  ChatSummaryDTO,
  CommentDTO,
  FileDTO,
  LikeDTO,
  MediaDTO,
  MessageDTO,
  MessageNotificationDTO,
  PageBookingDTO,
  PageChatSummaryDTO,
  PageLikeDTO,
  PageMessageDTO,
  PagePostResponseDTO,
  PageUserDTO,
  Pageable,
  PageableObject,
  PostDTO,
  PostResponseDTO,
  SortObject,
  UserDTO,
  UserExtendedDTO,
  WorkspaceDTO,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltMap, [FullType(String), FullType(String)]),
        () => MapBuilder<String, String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UserExtendedDTO)]),
        () => ListBuilder<UserExtendedDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MessageNotificationDTO)]),
        () => ListBuilder<MessageNotificationDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UserDTO)]),
        () => ListBuilder<UserDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WorkspaceDTO)]),
        () => ListBuilder<WorkspaceDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CommentDTO)]),
        () => ListBuilder<CommentDTO>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
