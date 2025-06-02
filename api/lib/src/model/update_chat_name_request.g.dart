// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_chat_name_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateChatNameRequest extends UpdateChatNameRequest {
  @override
  final String newName;

  factory _$UpdateChatNameRequest(
          [void Function(UpdateChatNameRequestBuilder)? updates]) =>
      (new UpdateChatNameRequestBuilder()..update(updates))._build();

  _$UpdateChatNameRequest._({required this.newName}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        newName, r'UpdateChatNameRequest', 'newName');
  }

  @override
  UpdateChatNameRequest rebuild(
          void Function(UpdateChatNameRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateChatNameRequestBuilder toBuilder() =>
      new UpdateChatNameRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateChatNameRequest && newName == other.newName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateChatNameRequest')
          ..add('newName', newName))
        .toString();
  }
}

class UpdateChatNameRequestBuilder
    implements Builder<UpdateChatNameRequest, UpdateChatNameRequestBuilder> {
  _$UpdateChatNameRequest? _$v;

  String? _newName;
  String? get newName => _$this._newName;
  set newName(String? newName) => _$this._newName = newName;

  UpdateChatNameRequestBuilder() {
    UpdateChatNameRequest._defaults(this);
  }

  UpdateChatNameRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newName = $v.newName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateChatNameRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UpdateChatNameRequest;
  }

  @override
  void update(void Function(UpdateChatNameRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateChatNameRequest build() => _build();

  _$UpdateChatNameRequest _build() {
    final _$result = _$v ??
        new _$UpdateChatNameRequest._(
          newName: BuiltValueNullFieldError.checkNotNull(
              newName, r'UpdateChatNameRequest', 'newName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
