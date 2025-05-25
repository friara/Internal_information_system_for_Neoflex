// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sort_object.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SortObject extends SortObject {
  @override
  final bool? unsorted;
  @override
  final bool? empty;
  @override
  final bool? sorted;

  factory _$SortObject([void Function(SortObjectBuilder)? updates]) =>
      (new SortObjectBuilder()..update(updates))._build();

  _$SortObject._({this.unsorted, this.empty, this.sorted}) : super._();

  @override
  SortObject rebuild(void Function(SortObjectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SortObjectBuilder toBuilder() => new SortObjectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SortObject &&
        unsorted == other.unsorted &&
        empty == other.empty &&
        sorted == other.sorted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unsorted.hashCode);
    _$hash = $jc(_$hash, empty.hashCode);
    _$hash = $jc(_$hash, sorted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SortObject')
          ..add('unsorted', unsorted)
          ..add('empty', empty)
          ..add('sorted', sorted))
        .toString();
  }
}

class SortObjectBuilder implements Builder<SortObject, SortObjectBuilder> {
  _$SortObject? _$v;

  bool? _unsorted;
  bool? get unsorted => _$this._unsorted;
  set unsorted(bool? unsorted) => _$this._unsorted = unsorted;

  bool? _empty;
  bool? get empty => _$this._empty;
  set empty(bool? empty) => _$this._empty = empty;

  bool? _sorted;
  bool? get sorted => _$this._sorted;
  set sorted(bool? sorted) => _$this._sorted = sorted;

  SortObjectBuilder() {
    SortObject._defaults(this);
  }

  SortObjectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unsorted = $v.unsorted;
      _empty = $v.empty;
      _sorted = $v.sorted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SortObject other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$SortObject;
  }

  @override
  void update(void Function(SortObjectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SortObject build() => _build();

  _$SortObject _build() {
    final _$result = _$v ??
        new _$SortObject._(
          unsorted: unsorted,
          empty: empty,
          sorted: sorted,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
