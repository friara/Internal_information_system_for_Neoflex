// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommentDTO extends CommentDTO {
  @override
  final int? id;
  @override
  final DateTime? createdWhen;
  @override
  final int? postId;
  @override
  final int? userId;
  @override
  final String? textToComm;
  @override
  final String? answerToComm;

  factory _$CommentDTO([void Function(CommentDTOBuilder)? updates]) =>
      (new CommentDTOBuilder()..update(updates))._build();

  _$CommentDTO._(
      {this.id,
      this.createdWhen,
      this.postId,
      this.userId,
      this.textToComm,
      this.answerToComm})
      : super._();

  @override
  CommentDTO rebuild(void Function(CommentDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentDTOBuilder toBuilder() => new CommentDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommentDTO &&
        id == other.id &&
        createdWhen == other.createdWhen &&
        postId == other.postId &&
        userId == other.userId &&
        textToComm == other.textToComm &&
        answerToComm == other.answerToComm;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdWhen.hashCode);
    _$hash = $jc(_$hash, postId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, textToComm.hashCode);
    _$hash = $jc(_$hash, answerToComm.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommentDTO')
          ..add('id', id)
          ..add('createdWhen', createdWhen)
          ..add('postId', postId)
          ..add('userId', userId)
          ..add('textToComm', textToComm)
          ..add('answerToComm', answerToComm))
        .toString();
  }
}

class CommentDTOBuilder implements Builder<CommentDTO, CommentDTOBuilder> {
  _$CommentDTO? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  DateTime? _createdWhen;
  DateTime? get createdWhen => _$this._createdWhen;
  set createdWhen(DateTime? createdWhen) => _$this._createdWhen = createdWhen;

  int? _postId;
  int? get postId => _$this._postId;
  set postId(int? postId) => _$this._postId = postId;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  String? _textToComm;
  String? get textToComm => _$this._textToComm;
  set textToComm(String? textToComm) => _$this._textToComm = textToComm;

  String? _answerToComm;
  String? get answerToComm => _$this._answerToComm;
  set answerToComm(String? answerToComm) => _$this._answerToComm = answerToComm;

  CommentDTOBuilder() {
    CommentDTO._defaults(this);
  }

  CommentDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _createdWhen = $v.createdWhen;
      _postId = $v.postId;
      _userId = $v.userId;
      _textToComm = $v.textToComm;
      _answerToComm = $v.answerToComm;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommentDTO other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CommentDTO;
  }

  @override
  void update(void Function(CommentDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommentDTO build() => _build();

  _$CommentDTO _build() {
    final _$result = _$v ??
        new _$CommentDTO._(
          id: id,
          createdWhen: createdWhen,
          postId: postId,
          userId: userId,
          textToComm: textToComm,
          answerToComm: answerToComm,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
