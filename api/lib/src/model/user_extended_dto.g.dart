// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_extended_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserExtendedDTO extends UserExtendedDTO {
  @override
  final int? id;
  @override
  final String? login;
  @override
  final String? roleName;
  @override
  final String? lastName;
  @override
  final String? firstName;
  @override
  final String? patronymic;
  @override
  final String? appointment;
  @override
  final Date? birthday;
  @override
  final String? avatarUrl;
  @override
  final String? phoneNumber;
  @override
  final String? password;

  factory _$UserExtendedDTO([void Function(UserExtendedDTOBuilder)? updates]) =>
      (new UserExtendedDTOBuilder()..update(updates))._build();

  _$UserExtendedDTO._(
      {this.id,
      this.login,
      this.roleName,
      this.lastName,
      this.firstName,
      this.patronymic,
      this.appointment,
      this.birthday,
      this.avatarUrl,
      this.phoneNumber,
      this.password})
      : super._();

  @override
  UserExtendedDTO rebuild(void Function(UserExtendedDTOBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserExtendedDTOBuilder toBuilder() =>
      new UserExtendedDTOBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserExtendedDTO &&
        id == other.id &&
        login == other.login &&
        roleName == other.roleName &&
        lastName == other.lastName &&
        firstName == other.firstName &&
        patronymic == other.patronymic &&
        appointment == other.appointment &&
        birthday == other.birthday &&
        avatarUrl == other.avatarUrl &&
        phoneNumber == other.phoneNumber &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, login.hashCode);
    _$hash = $jc(_$hash, roleName.hashCode);
    _$hash = $jc(_$hash, lastName.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, patronymic.hashCode);
    _$hash = $jc(_$hash, appointment.hashCode);
    _$hash = $jc(_$hash, birthday.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, phoneNumber.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserExtendedDTO')
          ..add('id', id)
          ..add('login', login)
          ..add('roleName', roleName)
          ..add('lastName', lastName)
          ..add('firstName', firstName)
          ..add('patronymic', patronymic)
          ..add('appointment', appointment)
          ..add('birthday', birthday)
          ..add('avatarUrl', avatarUrl)
          ..add('phoneNumber', phoneNumber)
          ..add('password', password))
        .toString();
  }
}

class UserExtendedDTOBuilder
    implements Builder<UserExtendedDTO, UserExtendedDTOBuilder> {
  _$UserExtendedDTO? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _login;
  String? get login => _$this._login;
  set login(String? login) => _$this._login = login;

  String? _roleName;
  String? get roleName => _$this._roleName;
  set roleName(String? roleName) => _$this._roleName = roleName;

  String? _lastName;
  String? get lastName => _$this._lastName;
  set lastName(String? lastName) => _$this._lastName = lastName;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _patronymic;
  String? get patronymic => _$this._patronymic;
  set patronymic(String? patronymic) => _$this._patronymic = patronymic;

  String? _appointment;
  String? get appointment => _$this._appointment;
  set appointment(String? appointment) => _$this._appointment = appointment;

  Date? _birthday;
  Date? get birthday => _$this._birthday;
  set birthday(Date? birthday) => _$this._birthday = birthday;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  String? _phoneNumber;
  String? get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String? phoneNumber) => _$this._phoneNumber = phoneNumber;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  UserExtendedDTOBuilder() {
    UserExtendedDTO._defaults(this);
  }

  UserExtendedDTOBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _login = $v.login;
      _roleName = $v.roleName;
      _lastName = $v.lastName;
      _firstName = $v.firstName;
      _patronymic = $v.patronymic;
      _appointment = $v.appointment;
      _birthday = $v.birthday;
      _avatarUrl = $v.avatarUrl;
      _phoneNumber = $v.phoneNumber;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserExtendedDTO other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UserExtendedDTO;
  }

  @override
  void update(void Function(UserExtendedDTOBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserExtendedDTO build() => _build();

  _$UserExtendedDTO _build() {
    final _$result = _$v ??
        new _$UserExtendedDTO._(
          id: id,
          login: login,
          roleName: roleName,
          lastName: lastName,
          firstName: firstName,
          patronymic: patronymic,
          appointment: appointment,
          birthday: birthday,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          password: password,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
