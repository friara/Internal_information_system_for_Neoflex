// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BookingRequestDTO extends BookingRequestDTO {
  @override
  final int workspaceId;
  @override
  final DateTime bookingStart;
  @override
  final DateTime bookingEnd;

  factory _$BookingRequestDTO(
          [void Function(BookingRequestDTOBuilder)? updates]) =>
      (new BookingRequestDTOBuilder()..update(updates))._build();

  _$BookingRequestDTO._(
      {required this.workspaceId,
      required this.bookingStart,
      required this.bookingEnd})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        workspaceId, r'BookingRequestDTO', 'workspaceId');
    BuiltValueNullFieldError.checkNotNull(
        bookingStart, r'BookingRequestDTO', 'bookingStart');
    BuiltValueNullFieldError.checkNotNull(
        bookingEnd, r'BookingRequestDTO', 'bookingEnd');
  }

  @override
  BookingRequestDTO rebuild(void Function(BookingRequestDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BookingRequestDTOBuilder toBuilder() =>
      new BookingRequestDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BookingRequestDTO &&
        workspaceId == other.workspaceId &&
        bookingStart == other.bookingStart &&
        bookingEnd == other.bookingEnd;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, workspaceId.hashCode);
    _$hash = $jc(_$hash, bookingStart.hashCode);
    _$hash = $jc(_$hash, bookingEnd.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BookingRequestDTO')
          ..add('workspaceId', workspaceId)
          ..add('bookingStart', bookingStart)
          ..add('bookingEnd', bookingEnd))
        .toString();
  }
}

class BookingRequestDTOBuilder
    implements Builder<BookingRequestDTO, BookingRequestDTOBuilder> {
  _$BookingRequestDTO? _$v;

  int? _workspaceId;
  int? get workspaceId => _$this._workspaceId;
  set workspaceId(int? workspaceId) => _$this._workspaceId = workspaceId;

  DateTime? _bookingStart;
  DateTime? get bookingStart => _$this._bookingStart;
  set bookingStart(DateTime? bookingStart) =>
      _$this._bookingStart = bookingStart;

  DateTime? _bookingEnd;
  DateTime? get bookingEnd => _$this._bookingEnd;
  set bookingEnd(DateTime? bookingEnd) => _$this._bookingEnd = bookingEnd;

  BookingRequestDTOBuilder() {
    BookingRequestDTO._defaults(this);
  }

  BookingRequestDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _workspaceId = $v.workspaceId;
      _bookingStart = $v.bookingStart;
      _bookingEnd = $v.bookingEnd;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BookingRequestDTO other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$BookingRequestDTO;
  }

  @override
  void update(void Function(BookingRequestDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BookingRequestDTO build() => _build();

  _$BookingRequestDTO _build() {
    final _$result = _$v ??
        new _$BookingRequestDTO._(
          workspaceId: BuiltValueNullFieldError.checkNotNull(
              workspaceId, r'BookingRequestDTO', 'workspaceId'),
          bookingStart: BuiltValueNullFieldError.checkNotNull(
              bookingStart, r'BookingRequestDTO', 'bookingStart'),
          bookingEnd: BuiltValueNullFieldError.checkNotNull(
              bookingEnd, r'BookingRequestDTO', 'bookingEnd'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
