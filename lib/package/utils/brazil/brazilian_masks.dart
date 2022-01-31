import 'package:flutter_easy_tools/flutter_easy_tools.dart';

class BrazilianMasks {
  BrazilianMasks._();

  static const Map<String, String> filters = Format.filterMask;

  static const String cpf = "000.000.000-00";
  static const String cnpj = "00.000.000/0000-00";
  static const String date = "00/00/0000";
  static const String time = "00:00:00";
  static const String dateTime = "00/00/0000 00:00:00";
  static const String cepNumber = "00000000";
  static const String cepDash = "00000-000";
  static const String cardNumber = "0000 0000 0000 0000";
  static const String cardCvv = "0000";
  static const String cardDateYYYY = "00/0000";
  static const String cardDateYY = "00/00";

  static final List<String> phones = [
    "0000 0000",
    "00000 0000",
    "(00) 0000 0000",
    "(00) 00000 0000",
    "+00 (00) 0000 0000",
    "+00 (00) 00000 0000",
  ];

  static List<String> choosePhones(List<int> acceptedNumbers) {
    List<String> result = [];
    for (var element in phones) {
      String numbers = element.replaceAll(RegExp(r'[^0-9]'), "");
      if (acceptedNumbers.contains(numbers.length)) result.add(element);
    }
    return result;
  }

  static String integer(int placesQuantity) {
    assert(placesQuantity > 0);
    return "0" * placesQuantity;
  }
}

/*
enum TextFieldMaskType {
  cpf,
  cnpj,
  cpfCnpj,
  date,
  dateTime,
  time,
  cardNumber,
  cardCvv,
  cardDateYYYY,
  cardDateYY,
  money,
  integer,
  decimal,
  name,
  email,
  password,
  multiText,
  cep,
  search,
  chat,
  phones,
  landlineCell,
}
*/
