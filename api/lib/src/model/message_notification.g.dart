// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_notification.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessageNotification extends MessageNotification {
  @override
  final int? id;
  @override
  final int? sender;
  @override
  final String? content;
  @override
  final DateTime? timestamp;
  @override
  final int? chatId;

  factory _$MessageNotification(
          [void Function(MessageNotificationBuilder)? updates]) =>
      (new MessageNotificationBuilder()..update(updates))._build();

  _$MessageNotification._(
      {this.id, this.sender, this.content, this.timestamp, this.chatId})
      : super._();

  @override
  MessageNotification rebuild(
          void Function(MessageNotificationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageNotificationBuilder toBuilder() =>
      new MessageNotificationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageNotification &&
        id == other.id &&
        sender == other.sender &&
        content == other.content &&
        timestamp == other.timestamp &&
        chatId == other.chatId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sender.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jc(_$hash, chatId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MessageNotification')
          ..add('id', id)
          ..add('sender', sender)
          ..add('content', content)
          ..add('timestamp', timestamp)
          ..add('chatId', chatId))
        .toString();
  }
}

class MessageNotificationBuilder
    implements Builder<MessageNotification, MessageNotificationBuilder> {
  _$MessageNotification? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _sender;
  int? get sender => _$this._sender;
  set sender(int? sender) => _$this._sender = sender;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  int? _chatId;
  int? get chatId => _$this._chatId;
  set chatId(int? chatId) => _$this._chatId = chatId;

  MessageNotificationBuilder() {
    MessageNotification._defaults(this);
  }

  MessageNotificationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sender = $v.sender;
      _content = $v.content;
      _timestamp = $v.timestamp;
      _chatId = $v.chatId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageNotification other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$MessageNotification;
  }

  @override
  void update(void Function(MessageNotificationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageNotification build() => _build();

  _$MessageNotification _build() {
    final _$result = _$v ??
        new _$MessageNotification._(
          id: id,
          sender: sender,
          content: content,
          timestamp: timestamp,
          chatId: chatId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
