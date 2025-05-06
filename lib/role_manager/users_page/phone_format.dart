import 'package:flutter/services.dart';

class RuPhoneInputFormatter extends TextInputFormatter {
  String _formattedPhone = "";
  bool _isRu = false;

  RuPhoneInputFormatter({String? initialText}) {
    if (initialText != null) {
      formatEditUpdate(
          TextEditingValue.empty, TextEditingValue(text: initialText));
    }
  }

  String getMaskedPhone() => _formattedPhone;

  String getClearPhone() {
    if (_formattedPhone.isEmpty) return '';
    if (!_isRu) return _formattedPhone.replaceAll(RegExp(r'\D'), '');
    return _formattedPhone.replaceAll(RegExp(r'\D'), '').substring(1);
  }

  bool isDone() =>
      _isRu ? _formattedPhone.replaceAll(RegExp(r'\D'), '').length > 10 : true;

  bool get isRussian => _isRu;

  String _formattingPhone(String text) {
    text = text.replaceAll(RegExp(r'\D'), '');
    if (text.isNotEmpty) {
      String phone = '';
      if (['7', '8', '9'].contains(text[0])) {
        _isRu = true;
        if (text[0] == '9') {
          text = '7$text';
        }
        String firstSymbols = (text[0] == '8') ? '8' : '+7';
        phone = '$firstSymbols ';
        if (text.length > 1) {
          phone += '(';
          phone += text.substring(1, text.length < 4 ? text.length : 4);
        }
        if (text.length >= 5) {
          phone += ') ';
          phone += text.substring(4, text.length < 7 ? text.length : 7);
        }
        if (text.length >= 8) {
          phone += '-';
          phone += text.substring(7, text.length < 9 ? text.length : 9);
        }
        if (text.length >= 10) {
          phone += '-';
          phone += text.substring(9, text.length < 11 ? text.length : 11);
        }
      } else {
        _isRu = false;
        return '+$text';
      }
      return phone;
    }
    return '';
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    int selectionStart = oldValue.selection.end;

    if (oldValue.text == '${newValue.text} ') {
      _formattedPhone = '';
      return TextEditingValue(
        text: _formattedPhone,
        selection: TextSelection(
          baseOffset: _formattedPhone.length,
          extentOffset: _formattedPhone.length,
          affinity: newValue.selection.affinity,
          isDirectional: newValue.selection.isDirectional,
        ),
      );
    }

    if (selectionStart != _formattedPhone.length) {
      _formattedPhone = _formattingPhone(text);
      return TextEditingValue(
        text: _formattedPhone,
        selection: TextSelection(
          baseOffset: newValue.selection.baseOffset,
          extentOffset: newValue.selection.baseOffset,
          affinity: newValue.selection.affinity,
          isDirectional: newValue.selection.isDirectional,
        ),
      );
    }

    _formattedPhone = _formattingPhone(text);
    return TextEditingValue(
      text: _formattedPhone,
      selection: TextSelection.collapsed(offset: _formattedPhone.length),
    );
  }
}
