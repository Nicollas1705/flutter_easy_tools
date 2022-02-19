part of flutter_easy_tools;

class Format {
  Format._();

  static const Map<String, String> filterMask = {
    "0": r'[0-9]',
    "A": r'[A-Z]',
    "a": r'[a-z]',
    "_": r'[A-Za-z]',
    "@": r'[a-zA-Z0-9]',
    "*": r'',
  };

  /// Apply the mask "000.000.000-00" (cpf) or "00.000.000/0000-00" (cnpj)
  ///
  /// Ignore non-numeric characters
  static String cpfCnpj(String from) {
    from = from.replaceAll(RegExp(r'[^0-9]'), "");
    return from.length <= 11 ? cpf(from) : cnpj(from);
  }

  /// Apply the mask "000.000.000-00"
  static String cpf(String from) {
    return _singleMasked(from, mask: "000.000.000-00");
  }

  /// Apply the mask "00.000.000/0000-00"
  static String cnpj(String from) {
    return _singleMasked(from, mask: "00.000.000/0000-00");
  }

  /// Upper case on the first letter, and the rest on lower case
  static String upperFirstLowerRest(String value) {
    if (value.length > 1) {
      return "${value.substring(0, 1).toUpperCase()}${value.substring(1).toLowerCase()}";
    } else {
      return value.toUpperCase();
    }
  }

  /// Upper case on the first letter, and the rest keeps the same
  static String upperFirstKeepRest(String value) {
    if (value.length > 1) {
      return "${value.substring(0, 1).toUpperCase()}${value.substring(1)}";
    } else {
      return value.toUpperCase();
    }
  }

  static String upperFirstLetterOfEachWord(String value) {
    List<String> words = value.split(" ");
    String result = "";
    for (var element in words) {
      result += upperFirstLowerRest(value);
      if (element != words[words.length - 1]) result += " ";
    }
    return result;
  }

  /// Same as toUpperCase() method
  static String upper(String value) {
    return value.toUpperCase();
  }

  /// Same as toLowerCase() method
  static String lower(String value) {
    return value.toLowerCase();
  }

  /// Returns a double value of any kind of [currency]
  static double fromCurrencyToDouble(
    dynamic currency, {
    int floatPrecision = 6,
  }) {
    final result = monetary(
      currency,
      decimalSeparator: ".",
      thousandSeparator: "",
      floatPrecision: floatPrecision,
    );
    return double.parse(result);
  }

  /// Remove the characters passed in [removedCharacters]
  static String removeCharacters(
    String from,
    String removedCharacters, {
    bool trim = true,
  }) {
    if (trim) from = from.trim();
    for (int i = 0; i < removedCharacters.length; i++) {
      from = from.replaceAll(removedCharacters[i], "");
    }
    return from;
  }

  /// Remove gramatical accents and the ponctuation in [removedPonctuation]
  static String removeAccentAndPonctuation(
    String from, {
    String removedPonctuation = ",.!?;:()[]{}}",
    bool removeDouplicatedSpaces = true,
    bool trim = true,
  }) {
    if (trim) from = from.trim();

    List<Map<String, String>> values = [
      {
        "to": "a",
        "from": "áàãâä",
      },
      {
        "to": "e",
        "from": "éèêë",
      },
      {
        "to": "i",
        "from": "íìîï",
      },
      {
        "to": "o",
        "from": "óòôõö",
      },
      {
        "to": "u",
        "from": "úùûü",
      },
      {
        "to": "y",
        "from": "ýÿ",
      },
      {
        "to": "c",
        "from": "ç",
      },
      {
        "to": "n",
        "from": "ñ",
      },
    ];

    for (Map<String, String> map in values) {
      for (int i = 0; i < map["from"]!.length; i++) {
        from = from.replaceAll(
          map["from"]![i],
          map["to"]!,
        );
        from = from.replaceAll(
          map["from"]![i].toUpperCase(),
          map["to"]!.toUpperCase(),
        );
      }
    }

    if (removedPonctuation.isNotEmpty) {
      for (int i = 0; i < removedPonctuation.length; i++) {
        from = from.replaceAll(removedPonctuation[i], " ");
      }
    }

    if (removeDouplicatedSpaces) {
      while (from.contains("  ")) {
        from = from.replaceAll("  ", " ");
      }
    }

    return from;
  }

  /// It returns a [quantity] of words from [text]
  static String numberOfWords(
    String text, {
    int quantity = 1,
  }) {
    List<String> values = text.split(" ");
    String returned = "";
    for (int i = 0; i < quantity && i < values.length; i++) {
      returned += values[i];
      if (i + 1 != quantity && i + 1 != values.length) {
        returned += " ";
      }
    }
    return returned;
  }

  static int countCharacters(
    String text,
    String character,
  ) {
    return character.allMatches(text).length;
  }

  // Convert url code (example: %20) to a normal text (if it contains "%")
  static String uriDecoder(String uri) {
    if (uri.contains("%")) {
      return Uri.decodeFull(uri);
    } else {
      return uri;
    }
  }

  // Convert normal text to a url code (example: %20) (if it contains "%")
  static String uriEncoder(String uri) {
    if (uri.contains("%")) {
      return Uri.encodeFull(uri);
    } else {
      return uri;
    }
  }

  /// It tries to convert any value received to currency
  /// 
  /// Example: "12345,6" => "12.345,60" (default separators)
  /// 
  /// When [hideCentsWhenZero] is true: instead of "1,00" is "1"
  /// 
  /// Returns [returnWhenFree] if it is not null and the result is "0,00"
  static String monetary(
    dynamic from, {
    String leftSymbol = "",
    String rightSymbol = "",
    String decimalSeparator = ",",
    String thousandSeparator = ".",
    int floatPrecision = 2,
    bool hideCentsWhenZero = false,
    String? returnWhenFree,
  }) {
    String _getCurrencyString(String integer, [String cents = ""]) {
      // Integer
      integer = integer.replaceAll(".", "").replaceAll(",", "");
      if (integer.length > 3 && thousandSeparator.isNotEmpty) {
        List<String> splitted = integer.split("");
        List<String> result = splitted;
        int count = 0;
        for (int i = splitted.length - 1; i > 0; i--) {
          count++;
          if (count % 3 == 0 && count != 0) {
            result.insert(i, thousandSeparator);
          }
        }
        integer = result.join();
      }
      if (integer.isEmpty) integer = "0";

      // Cents
      cents = cents.replaceAll(".", "").replaceAll(",", "");
      if (cents.length > floatPrecision) {
        cents = cents.substring(0, floatPrecision);
      } else if (cents.length < floatPrecision) {
        cents = cents.padRight(floatPrecision, "0");
      }
      if (int.tryParse(cents) == 0 && hideCentsWhenZero) {
        cents = "";
      }

      if (returnWhenFree != null &&
          int.tryParse(integer) == 0 &&
          (int.tryParse(cents) == 0 || cents.isEmpty)) {
        return returnWhenFree;
      }
      if (cents.isNotEmpty) {
        cents = "$decimalSeparator$cents";
      }
      var result = "$leftSymbol$integer$cents$rightSymbol";
      return result;
    }

    String _separateIntegerAndCents(String numbers) {
      List<String> splitted = numbers.split("");
      for (int i = splitted.length - 1; i >= 0; i--) {
        if (",.".contains(splitted[i])) {
          String integer = "";
          String cents = "";
          for (int j = 0; j < splitted.length; j++) {
            if (j < i) {
              integer += splitted[j];
            } else if (j > i) {
              cents += splitted[j];
            }
          }
          return _getCurrencyString(integer, cents);
        }
      }
      return _getCurrencyString("0");
    }

    RegExp regexNumbers = RegExp(r'[^0-9,.]');
    String numbers = from.toString().replaceAll(regexNumbers, "");
    dynamic result = int.tryParse(numbers) ?? double.tryParse(numbers);
    if (result == null) {
      bool containsSomeNumber = false;
      for (int i = 0; i < 10; i++) {
        if (numbers.contains("$i")) {
          containsSomeNumber = true;
          break;
        }
      }
      if (containsSomeNumber) {
        if (numbers.contains(".") && numbers.contains(",")) {
          return _separateIntegerAndCents(numbers);
        } else {
          numbers = numbers.replaceAll(",", ".");
          int dotQuantity = ".".allMatches(numbers).length;
          if (dotQuantity == 1) {
            return _separateIntegerAndCents(numbers);
          } else {
            numbers = numbers.replaceAll(".", "");
            return _getCurrencyString(numbers);
          }
        }
      } else {
        return _getCurrencyString("0");
      }
    } else {
      if (result.toString() == "Infinity") {
        return _getCurrencyString("0");
      } else if (result is int) {
        return _getCurrencyString(result.toString());
      } else {
        String integer = result.toString().split(".")[0];
        String cents = result.toString().split(".")[1];
        return _getCurrencyString(integer, cents);
      }
    }
  }

  /// Format [from] string to a single [mask] or multi [masks]
  ///
  /// Example: masked("123456", "000-000") => "123-456"
  ///
  /// The [filters] can be changed to include costumized masks {'FILTER': 'REGEX PATTERN'}
  ///
  /// [addFilters] can be used to add more filters to the [filters] {'FILTER': 'REGEX PATTERN'}
  ///
  /// Default filters:
  /// * "0": Only numbers
  /// * "A": Upper case letters
  /// * "a": Lower case letters
  /// * "_": Any case letters
  /// * "@": Any case letters and numbers
  /// * "*": Any character
  static String masked(
    String from, {
    String? mask,
    List<String>? masks,
    Map<String, String>? addFilters,
    Map<String, String> filters = const {
      "0": r'[0-9]',
      "A": r'[A-Z]',
      "a": r'[a-z]',
      "_": r'[A-Za-z]',
      "@": r'[a-zA-Z0-9]',
      "*": r'',
    },
  }) {
    // Avoiding const Map's
    addFilters ??= {};
    filters = {
      ...filters,
      ...addFilters,
    };

    if (mask != null && mask.isNotEmpty) {
      return _singleMasked(
        from,
        mask: mask,
        filters: filters,
      );
    } else if (masks != null && masks.isNotEmpty) {
      return _multiMasked(
        from,
        masks: masks,
        filters: filters,
      );
    }
    return from;
  }

  static String _singleMasked(
    String from, {
    required String mask,
    Map<String, String> filters = filterMask,
  }) {
    String result = "";
    int fromIndex = 0;
    for (int i = 0; i < mask.length; i++) {
      if (fromIndex >= from.length) break;
      if (filters.containsKey(mask[i])) {
        final RegExp r = RegExp(filters[mask[i]]!);
        if (r.hasMatch(from[fromIndex])) {
          result += from[fromIndex];
        } else {
          i--;
        }
        fromIndex++;
      } else {
        result += mask[i];
      }
    }

    // Remove the rest of the mask.
    // Example: filter(from: "12 ", mask: "00-0") => "12" (not "12-")
    if (true) {
      String filterKeys = "";
      filters.forEach((key, _) => filterKeys += key);
      String restMask = mask.replaceAll(RegExp("[$filterKeys]"), "");
      for (int i = result.length - 1; i >= 0; i--) {
        if (restMask.contains(result.substring(result.length - 1))) {
          result = result.substring(0, result.length - 1);
        } else {
          break;
        }
      }
    }
    return result;
  }

  static String _multiMasked(
    String from, {
    required List<String> masks,
    Map<String, String> filters = filterMask,
  }) {
    // [...masks] is to avoid const Lists
    masks = [...masks];
    if (masks.isEmpty) return from;

    if (masks.length > 1) {
      String pattern = r"[^";
      filters.forEach((key, _) => pattern += key);
      pattern += r"]";

      final r = RegExp(pattern);
      masks.sort((a, b) {
        int aInt = a.replaceAll(r, "").length;
        int bInt = b.replaceAll(r, "").length;
        return aInt - bInt;
      });

      late String result;
      for (String mask in masks) {
        final String fakeMask = mask + mask.substring(mask.length - 1);
        result = _singleMasked(
          from,
          mask: fakeMask,
          filters: filters,
        );
        if (result.length < fakeMask.length) {
          result = _singleMasked(
            from,
            mask: mask,
            filters: filters,
          );
          return result;
        }
      }
      return _singleMasked(
        from,
        mask: masks.last,
        filters: filters,
      );
    }
    return _singleMasked(
      from,
      mask: masks.first,
      filters: filters,
    );
  }
}
