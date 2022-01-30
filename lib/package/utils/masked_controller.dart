import 'package:flutter/cupertino.dart';
import 'package:flutter_easy_tools/flutter_package.dart';

class MaskedController extends TextEditingController {
  String? mask;
  List<String>? masks;
  Map<String, String>? filters;

  /// Can be used a single [mask] or multiple [masks]
  ///
  /// The [filters] can be changed to include costumized masks {'FILTER': 'REGEX PATTERN'}
  ///
  /// Default filters:
  /// * "0": Only numbers
  /// * "A": Upper case letters
  /// * "a": Lower case letters
  /// * "_": Any case letters
  /// * "@": Any case letters and numbers
  /// * "*": Any character
  MaskedController({
    String? initialText,
    this.mask,
    this.masks,
    this.filters,
  }) : super(text: initialText) {
    filters ??= Format.filterMask;
    addListener(() => updateText(text));
    updateText(text);
  }

  void updateText(String text) {
    this.text = Format.masked(
      text,
      mask: mask,
      masks: masks,
      filters: filters!,
    );
  }

  void updateMask(String? mask, List<String>? masks) {
    this.mask = mask;
    this.masks = masks;
    updateText(text);
  }

  void cursorToEnd() {
    selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      cursorToEnd();
    }
  }
}

class MonetaryController extends TextEditingController {
  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;
  double _lastValue = 0.0;

  MonetaryController({
    double initialValue = .0,
    this.decimalSeparator = ",",
    this.thousandSeparator = ".",
    this.rightSymbol = "",
    this.leftSymbol = "",
    this.precision = 2,
  }) {
    assert(precision >= 0);

    addListener(() => updateValue(numberValue));
    updateValue(initialValue);
  }

  void updateValue(double value) {
    double valueToUse = value;

    // This IF is due to the max precision of 'dart double'
    if (value.toStringAsFixed(0).length + precision > 17) {
      valueToUse = _lastValue;
    } else {
      _lastValue = value;
    }

    String masked = _applyMask(valueToUse);

    if (masked != text) {
      text = masked;
      int cursorPosition = super.text.length - rightSymbol.length;
      selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition),
      );
    }
  }

  double get numberValue {
    // The IFs is to avoid exceptions

    String noLeftSymbol = text.replaceFirst(leftSymbol, "");
    int lastIndex = noLeftSymbol.length - rightSymbol.length;
    if (lastIndex < 0) lastIndex = 0;
    String value = noLeftSymbol.substring(0, lastIndex);
    List<String> splitted = _getOnlyNumbers(value).split("");

    int index = splitted.length - precision;
    if (index < 0) index = 0;
    splitted.insert(index, '.');

    return double.parse(splitted.join() + "0");
  }

  String _getOnlyNumbers(String text) => text.replaceAll(RegExp(r"[^0-9]"), "");

  String _applyMask(double value) => Format.monetary(
        value,
        decimalSeparator: decimalSeparator,
        thousandSeparator: thousandSeparator,
        leftSymbol: leftSymbol,
        rightSymbol: rightSymbol,
        floatPrecision: precision,
      );
}
