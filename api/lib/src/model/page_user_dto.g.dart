// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageUserDTO extends PageUserDTO {
  @override
  final int? totalPages;
<<<<<<< Updated upstream
=======
  @override
  final int? totalElements;
  @override
  final bool? first;
  @override
  final bool? last;
>>>>>>> Stashed changes
  @override
  final int? totalElements;
  @override
  final int? size;
  @override
  final BuiltList<UserDTO>? content;
  @override
  final int? number;
  @override
  final SortObject? sort;
  @override
<<<<<<< Updated upstream
  final bool? first;
  @override
  final bool? last;
  @override
=======
>>>>>>> Stashed changes
  final int? numberOfElements;
  @override
  final PageableObject? pageable;
  @override
  final bool? empty;

  factory _$PageUserDTO([void Function(PageUserDTOBuilder)? updates]) =>
      (new PageUserDTOBuilder()..update(updates))._build();

  _$PageUserDTO._(
      {this.totalPages,
      this.totalElements,
<<<<<<< Updated upstream
=======
      this.first,
      this.last,
>>>>>>> Stashed changes
      this.size,
      this.content,
      this.number,
      this.sort,
<<<<<<< Updated upstream
      this.first,
      this.last,
=======
>>>>>>> Stashed changes
      this.numberOfElements,
      this.pageable,
      this.empty})
      : super._();

  @override
  PageUserDTO rebuild(void Function(PageUserDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageUserDTOBuilder toBuilder() => new PageUserDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageUserDTO &&
        totalPages == other.totalPages &&
        totalElements == other.totalElements &&
<<<<<<< Updated upstream
=======
        first == other.first &&
        last == other.last &&
>>>>>>> Stashed changes
        size == other.size &&
        content == other.content &&
        number == other.number &&
        sort == other.sort &&
<<<<<<< Updated upstream
        first == other.first &&
        last == other.last &&
=======
>>>>>>> Stashed changes
        numberOfElements == other.numberOfElements &&
        pageable == other.pageable &&
        empty == other.empty;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jc(_$hash, totalElements.hashCode);
<<<<<<< Updated upstream
=======
    _$hash = $jc(_$hash, first.hashCode);
    _$hash = $jc(_$hash, last.hashCode);
>>>>>>> Stashed changes
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, sort.hashCode);
<<<<<<< Updated upstream
    _$hash = $jc(_$hash, first.hashCode);
    _$hash = $jc(_$hash, last.hashCode);
=======
>>>>>>> Stashed changes
    _$hash = $jc(_$hash, numberOfElements.hashCode);
    _$hash = $jc(_$hash, pageable.hashCode);
    _$hash = $jc(_$hash, empty.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PageUserDTO')
          ..add('totalPages', totalPages)
          ..add('totalElements', totalElements)
<<<<<<< Updated upstream
=======
          ..add('first', first)
          ..add('last', last)
>>>>>>> Stashed changes
          ..add('size', size)
          ..add('content', content)
          ..add('number', number)
          ..add('sort', sort)
<<<<<<< Updated upstream
          ..add('first', first)
          ..add('last', last)
=======
>>>>>>> Stashed changes
          ..add('numberOfElements', numberOfElements)
          ..add('pageable', pageable)
          ..add('empty', empty))
        .toString();
  }
}

class PageUserDTOBuilder implements Builder<PageUserDTO, PageUserDTOBuilder> {
  _$PageUserDTO? _$v;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  int? _totalElements;
  int? get totalElements => _$this._totalElements;
  set totalElements(int? totalElements) =>
      _$this._totalElements = totalElements;

<<<<<<< Updated upstream
=======
  bool? _first;
  bool? get first => _$this._first;
  set first(bool? first) => _$this._first = first;

  bool? _last;
  bool? get last => _$this._last;
  set last(bool? last) => _$this._last = last;

>>>>>>> Stashed changes
  int? _size;
  int? get size => _$this._size;
  set size(int? size) => _$this._size = size;

  ListBuilder<UserDTO>? _content;
  ListBuilder<UserDTO> get content =>
      _$this._content ??= new ListBuilder<UserDTO>();
  set content(ListBuilder<UserDTO>? content) => _$this._content = content;

  int? _number;
  int? get number => _$this._number;
  set number(int? number) => _$this._number = number;

  SortObjectBuilder? _sort;
  SortObjectBuilder get sort => _$this._sort ??= new SortObjectBuilder();
  set sort(SortObjectBuilder? sort) => _$this._sort = sort;

<<<<<<< Updated upstream
  bool? _first;
  bool? get first => _$this._first;
  set first(bool? first) => _$this._first = first;

  bool? _last;
  bool? get last => _$this._last;
  set last(bool? last) => _$this._last = last;

=======
>>>>>>> Stashed changes
  int? _numberOfElements;
  int? get numberOfElements => _$this._numberOfElements;
  set numberOfElements(int? numberOfElements) =>
      _$this._numberOfElements = numberOfElements;

  PageableObjectBuilder? _pageable;
  PageableObjectBuilder get pageable =>
      _$this._pageable ??= new PageableObjectBuilder();
  set pageable(PageableObjectBuilder? pageable) => _$this._pageable = pageable;

  bool? _empty;
  bool? get empty => _$this._empty;
  set empty(bool? empty) => _$this._empty = empty;

  PageUserDTOBuilder() {
    PageUserDTO._defaults(this);
  }

  PageUserDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _totalPages = $v.totalPages;
      _totalElements = $v.totalElements;
<<<<<<< Updated upstream
=======
      _first = $v.first;
      _last = $v.last;
>>>>>>> Stashed changes
      _size = $v.size;
      _content = $v.content?.toBuilder();
      _number = $v.number;
      _sort = $v.sort?.toBuilder();
<<<<<<< Updated upstream
      _first = $v.first;
      _last = $v.last;
=======
>>>>>>> Stashed changes
      _numberOfElements = $v.numberOfElements;
      _pageable = $v.pageable?.toBuilder();
      _empty = $v.empty;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PageUserDTO other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$PageUserDTO;
  }

  @override
  void update(void Function(PageUserDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageUserDTO build() => _build();

  _$PageUserDTO _build() {
    _$PageUserDTO _$result;
    try {
      _$result = _$v ??
          new _$PageUserDTO._(
            totalPages: totalPages,
            totalElements: totalElements,
<<<<<<< Updated upstream
=======
            first: first,
            last: last,
>>>>>>> Stashed changes
            size: size,
            content: _content?.build(),
            number: number,
            sort: _sort?.build(),
<<<<<<< Updated upstream
            first: first,
            last: last,
=======
>>>>>>> Stashed changes
            numberOfElements: numberOfElements,
            pageable: _pageable?.build(),
            empty: empty,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();

        _$failedField = 'sort';
        _sort?.build();

        _$failedField = 'pageable';
        _pageable?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'PageUserDTO', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
