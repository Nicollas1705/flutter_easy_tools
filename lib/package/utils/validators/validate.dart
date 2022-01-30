

import 'package:flutter_easy_tools/flutter_easy_tools.dart';

abstract class Validate {
  static const int minLengthName = 5;

  static bool _validateCpf(String? cpf) {
    if (cpf == null) return false;
    var numbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;
    List<int> digits = numbers.split('').map((d) => int.parse(d)).toList();

    // Compute first verifying digit
    var calcDv1 = 0;
    for (var i in Iterable<int>.generate(9, (i) => 10 - i)) {
      calcDv1 += digits[10 - i] * i;
    }
    calcDv1 %= 11;
    var dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;
    if (digits[9] != dv1) return false;

    // Compute second verifying digit
    var calcDv2 = 0;
    for (var i in Iterable<int>.generate(10, (i) => 11 - i)) {
      calcDv2 += digits[11 - i] * i;
    }
    calcDv2 %= 11;
    var dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;
    if (digits[10] != dv2) return false;

    return true;
  }

  static bool _validateCnpj(String? cnpj) {
    if (cnpj == null) return false;
    var numbers = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 14) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(numbers)) return false;
    List<int> digits =
        numbers.split('').map((String d) => int.parse(d)).toList();

    // Compute first verifying digit
    var calcDv1 = 0;
    var j = 0;
    for (var i in Iterable<int>.generate(12, (i) => i < 4 ? 5 - i : 13 - i)) {
      calcDv1 += digits[j++] * i;
    }
    calcDv1 %= 11;
    var dv1 = calcDv1 < 2 ? 0 : 11 - calcDv1;
    if (digits[12] != dv1) return false;

    // Compute second verifying digit
    var calcDv2 = 0;
    j = 0;
    for (var i in Iterable<int>.generate(13, (i) => i < 5 ? 6 - i : 14 - i)) {
      calcDv2 += digits[j++] * i;
    }
    calcDv2 %= 11;
    var dv2 = calcDv2 < 2 ? 0 : 11 - calcDv2;
    if (digits[13] != dv2) return false;

    return true;
  }

  /// Returns [false] if the [value] < [minLength]; or [value]> [maxLength]
  ///
  /// If [value] is "null" (*String*), it returns [false]
  static bool text(dynamic value, {int minLength = 1, int? maxLength}) {
    if (value == null ||
        value.length < minLength ||
        (maxLength != null && value.length > maxLength)) return false;
    return true;
  }

  /// Returns [false] if the [value] < [minLength]; or > [maxLength]
  static bool list(List? value, {int minLength = 1, int? maxLength}) {
    if (value == null || value.length < minLength) return false;
    if (maxLength != null && value.length > maxLength) return false;
    return true;
  }

  static bool name(String? value, {int minLength = 4, int? maxLength}) {
    final valid = text(
      value,
      minLength: minLength,
      maxLength: maxLength,
    );
    if (!valid) return false;

    if (value!.contains("\n") || value.contains("  ")) return false;
    final regex = RegExp(
        r"^([a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ'\s]{2,}\s[a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ'\s]{1,}'?-?[a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ'\s]{1,}\s?([a-zA-ZáàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ'\s]{1,})?)$");
    return regex.hasMatch(value);
  }

  static bool email(String? value) {
    if (value == null) return false;
    final regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(value);
  }

  /// Validate CPF and CNPJ (both)
  static bool cpfCnpj(String? value) {
    return value != null && (_validateCpf(value) || _validateCnpj(value));
  }

  static bool cpf(String? value) {
    return value != null && _validateCpf(value);
  }

  static bool cnpj(String? value) {
    return value != null && _validateCnpj(value);
  }

  /// Check if the text [from] has this [quantity] of digits
  static bool digitsQuantity(String from, int quantity) {
    final regexNumbers = RegExp(r'[^0-9]');
    final numbers = from.replaceAll(regexNumbers, "");
    return numbers.length == quantity;
  }

  /// Validate the brazilian phone number
  /// 
  /// If [validateWithoutMask] is true, it will ignore the unused chars "+() -"
  static bool brazilianPhone(String value, {bool validateWithoutMask = true}) {
    value = value.replaceAll(RegExp(r"\d"), "0");
    for (var phone in BrazilianMasks.phones) {
      if (value == phone) return true;
      if (validateWithoutMask) {
        const chars = "+() -";
        final noCharValue = Format.removeCharacters(value, chars);
        final noCharPhone = Format.removeCharacters(phone, chars);
        if (noCharValue == noCharPhone) return true;
      }
    }
    return false;
  }
}
