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
import 'dart:typed_data';

import 'package:openapi/src/model/chat_dto.dart';
import 'package:openapi/src/model/comment_dto.dart';
import 'package:openapi/src/model/file_dto.dart';
import 'package:openapi/src/model/like_dto.dart';
import 'package:openapi/src/model/message_dto.dart';
import 'package:openapi/src/model/post_dto.dart';
import 'package:openapi/src/model/repost_dto.dart';
import 'package:openapi/src/model/upload_avatar_request.dart';
import 'package:openapi/src/model/user_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  ChatDTO,
  CommentDTO,
  FileDTO,
  LikeDTO,
  MessageDTO,
  PostDTO,
  RepostDTO,
  UploadAvatarRequest,
  UserDTO,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FileDTO)]),
        () => ListBuilder<FileDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ChatDTO)]),
        () => ListBuilder<ChatDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(MessageDTO)]),
        () => ListBuilder<MessageDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LikeDTO)]),
        () => ListBuilder<LikeDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RepostDTO)]),
        () => ListBuilder<RepostDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PostDTO)]),
        () => ListBuilder<PostDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(UserDTO)]),
        () => ListBuilder<UserDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(CommentDTO)]),
        () => ListBuilder<CommentDTO>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Uint8List)]),
        () => ListBuilder<Uint8List>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
