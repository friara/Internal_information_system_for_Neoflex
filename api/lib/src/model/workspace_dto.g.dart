// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorkspaceDTO extends WorkspaceDTO {
  @override
  final int? id;
  @override
  final String? workspaceName;
  @override
  final BuiltList<BookingDTO>? currentBookings;
  @override
  final bool? available;

  factory _$WorkspaceDTO([void Function(WorkspaceDTOBuilder)? updates]) =>
      (new WorkspaceDTOBuilder()..update(updates))._build();

  _$WorkspaceDTO._(
      {this.id, this.workspaceName, this.currentBookings, this.available})
      : super._();

  @override
  WorkspaceDTO rebuild(void Function(WorkspaceDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorkspaceDTOBuilder toBuilder() => new WorkspaceDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorkspaceDTO &&
        id == other.id &&
        workspaceName == other.workspaceName &&
        currentBookings == other.currentBookings &&
        available == other.available;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, workspaceName.hashCode);
    _$hash = $jc(_$hash, currentBookings.hashCode);
    _$hash = $jc(_$hash, available.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorkspaceDTO')
          ..add('id', id)
          ..add('workspaceName', workspaceName)
          ..add('currentBookings', currentBookings)
          ..add('available', available))
        .toString();
  }
}

class WorkspaceDTOBuilder
    implements Builder<WorkspaceDTO, WorkspaceDTOBuilder> {
  _$WorkspaceDTO? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _workspaceName;
  String? get workspaceName => _$this._workspaceName;
  set workspaceName(String? workspaceName) =>
      _$this._workspaceName = workspaceName;

  ListBuilder<BookingDTO>? _currentBookings;
  ListBuilder<BookingDTO> get currentBookings =>
      _$this._currentBookings ??= new ListBuilder<BookingDTO>();
  set currentBookings(ListBuilder<BookingDTO>? currentBookings) =>
      _$this._currentBookings = currentBookings;

  bool? _available;
  bool? get available => _$this._available;
  set available(bool? available) => _$this._available = available;

  WorkspaceDTOBuilder() {
    WorkspaceDTO._defaults(this);
  }

  WorkspaceDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _workspaceName = $v.workspaceName;
      _currentBookings = $v.currentBookings?.toBuilder();
      _available = $v.available;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorkspaceDTO other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$WorkspaceDTO;
  }

  @override
  void update(void Function(WorkspaceDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorkspaceDTO build() => _build();

  _$WorkspaceDTO _build() {
    _$WorkspaceDTO _$result;
    try {
      _$result = _$v ??
          new _$WorkspaceDTO._(
            id: id,
            workspaceName: workspaceName,
            currentBookings: _currentBookings?.build(),
            available: available,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'currentBookings';
        _currentBookings?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'WorkspaceDTO', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
