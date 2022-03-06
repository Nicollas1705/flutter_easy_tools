part of text_masking_controller;

enum MaskAutoComplete {
  lazy,
  quick,
}

class TextMaskingController extends TextEditingController {
  List<String> _masks = [];
  final Map<String, String> filters;
  final bool cursorToEndWhenUpdate;
  late MaskAutoComplete maskAutoComplete;

  /// A [TextEditingController] input with costumized [mask] (or [masks]).
  ///
  /// Can be used a single [mask] or multiple [masks].
  ///
  /// If using multiple [masks], it will automatically update according to the text size.
  ///
  /// The [filters] can be changed to include costumized masks {'FILTER': 'REGEX_PATTERN'}.
  ///
  /// If [cursorToEndWhenUpdate] is true, the cursor will be send to end of the text when types.
  ///
  /// The [maskAutoComplete] is to set the way to complete the mask, for example:
  /// * lazy: (mask "00--00") >> text: "1" >> when add a number (2) >> "12" (not completed);
  /// * quick:  (mask "00--00") >> text: "1" >> when add a number (2) >> "12--" (completed).
  ///
  /// #### Default [filters] values:
  /// | Key character     | Description                  | Regex pattern
  /// | :---------------- | :--------------------------- | :--------------
  /// | "0"               | Only numbers                 | [0-9]
  /// | "A"               | Upper case letters           | [A-Z]
  /// | "a"               | Lower case letters           | [a-z]
  /// | "@"               | Any case letters             | [a-zA-Z]
  /// | "#"               | Any case letters and numbers | [a-zA-Z0-9]
  TextMaskingController({
    String? initialText,
    String? mask,
    List<String>? masks,
    this.filters = const {
      "0": r'[0-9]',
      "A": r'[A-Z]',
      "a": r'[a-z]',
      "@": r'[a-zA-Z]',
      "#": r'[a-zA-Z0-9]',
    },
    this.cursorToEndWhenUpdate = false,
    this.maskAutoComplete = MaskAutoComplete.lazy,
  }) {
    updateMask(mask: mask, masks: masks);
    _oldText = initialText ?? _oldText;
    if (initialText != null) updateText(initialText);
    updateCursor();
    addListener(() => updateText(text));
  }

  /// Default [filters] values:
  /// | Key | Description
  /// | :-- | :----------
  /// | "0" | Only numbers
  /// | "A" | Upper case letters
  /// | "a" | Lower case letters
  /// | "@" | Any case letters
  /// | "#" | Any case letters and numbers
  static Map<String, String> get defaultFilters => {
        "0": r'[0-9]',
        "A": r'[A-Z]',
        "a": r'[a-z]',
        "@": r'[a-zA-Z]',
        "#": r'[a-zA-Z0-9]',
      };

  /// Ignore this.
  // ignore: constant_identifier_names
  static const int? _END = null;

  String _oldText = "";
  String? _oldMask;
  int _oldCursor = 0;
  int __currentCursor = 0;
  int get _currentCursor => __currentCursor;
  set _currentCursor(int value) {
    _oldCursor = _currentCursor;
    __currentCursor = value;
  }

  /// Changes to a single [mask] or multiple [masks].
  ///
  /// If using multiple [masks], it will automatically update according to the text size.
  void updateMask({String? mask, List<String>? masks}) {
    if (mask != null || (masks != null && masks.isNotEmpty)) {
      if (masks != null && masks.length > 1) {
        String allNonFilterKey = masks.join().split("").toSet().join();
        for (var key in filters.keys) {
          allNonFilterKey = allNonFilterKey.replaceAll(key, "");
        }
        // Sort according to the filter key quantity on each mask
        masks.sort((a, b) {
          for (var char in allNonFilterKey.split("")) {
            a = a.replaceAll(char, "");
            b = b.replaceAll(char, "");
          }
          return a.length.compareTo(b.length);
        });
      }
      _masks = masks ?? [mask!];
      _oldMask = _masks.first;
    } else {
      _masks = [];
      _oldMask = null;
    }
    updateText(text);
  }

  /// Updates the cursor position. If [newPosition] is null, go to end.
  void updateCursor([int? newPosition = _END]) =>
      _updateCurrentCursor(newPosition ?? text.length, false);
  void _updateCurrentCursor([
    int? newCursorPosition,
    bool calc = true,
  ]) {
    int newPosition = newCursorPosition ?? _currentCursor;
    String? currentMask = _currentMask();
    _oldMask ??= currentMask;
    final acpCurrentMask = _allowedCursorPositions(currentMask);
    final acpOldMask = _allowedCursorPositions(_oldMask);

    if (calc && acpOldMask.isNotEmpty) {
      // To ensure 'currentMask' is not null
      currentMask = currentMask!;
      final cursorAhead = _currentCursor > _oldCursor;
      final changedMask = currentMask != _oldMask;
      final filterKeys = filters.keys.join();

      // Which direction the cursor needs to move
      if (cursorAhead) {
        for (var i = newPosition; i < acpOldMask.length; i++) {
          if (acpOldMask[i]) {
            // Case (mask: "00--00"): "01|--2" >> add number >> "01--3|2" (the second allowed position)
            if (i <= 0 || !filterKeys.contains(_oldMask![i - 1])) continue;
            newPosition = i;
            break;
          }
        }
        // Case (mask: "00--00"): "1|" >> add number >> "12--|" (instead of "12|--")
        if (maskAutoComplete == MaskAutoComplete.quick && !changedMask) {
          String restText = "";
          if (newPosition <= text.length) {
            restText = _oldMask!.substring(newPosition, text.length);
          }
          bool containsFilterKey = false;
          if (restText.isNotEmpty) {
            for (var key in filters.keys) {
              if (restText.contains(key)) {
                containsFilterKey = true;
                break;
              }
            }
          }
          if (!containsFilterKey) newPosition = text.length + 1;
        }
      } else {
        if (newPosition > acpOldMask.length - 1) {
          newPosition = acpOldMask.length - 1;
        }
        // Case (mask: "00--00"): "12--|3" >> delete >> "12|--3" (instead of "12-|-3")
        if (!acpOldMask[newPosition]) {
          for (var i = newPosition; i >= 0; i--) {
            if (acpOldMask[i]) {
              newPosition = i;
              break;
            }
          }
        }
      }

      if (_masks.length > 1 && changedMask) {
        int cursorPosition = newPosition;
        if (cursorAhead && cursorPosition > _oldMask!.length) {
          // Case (masks: ["0", "0--0--0"]): "1|" >> add number >> "1--2|" (or quick: "1--2--|")
          newPosition = text.length;
        } else {
          String oldMaskFirstPart = _oldMask!.substring(0, cursorPosition);
          for (var char in _nonFilterKeyMask(_oldMask)?.split("") ?? []) {
            oldMaskFirstPart = oldMaskFirstPart.replaceAll(char, "");
          }
          // The filter keys quantity before the cursor ("12--34--56|7" >> 6 filter keys before cursor)
          int keyPosition = oldMaskFirstPart.length;

          for (var i = 0; i <= currentMask.length; i++) {
            // Set [keyPosition] position when complete the keys quantity before cursor previously
            if (keyPosition <= 0) {
              keyPosition = i;
              break;
            }
            // Count the filter keys until complete the [keyPosition] to put the cursor
            if (filterKeys.contains(currentMask[i])) {
              keyPosition--;
            }
          }
          newPosition = keyPosition;
        }
      }
    }

    // Case (mask: "--00--"): cursor will be only aside the filter keys (not "-|-12--" or "--12-|-")
    if (calc && acpCurrentMask.isNotEmpty) {
      newPosition = _allowedCursorRange(newPosition, acpCurrentMask);
    } else {
      if (newPosition < 0) newPosition = 0;
      if (newPosition > text.length) newPosition = text.length;
    }

    selection = TextSelection.fromPosition(
      TextPosition(offset: newPosition),
    );
  }

  // The range where the cursor can fit: mask: "---00-00--" >> cursor range: "|00-00|"
  int _allowedCursorRange(int cursorPosition, List<bool> acpMask) {
    int minCursorPosition = 0;
    int maxCursorPosition = text.length;
    int? maxCursorPositionByMask;

    if (acpMask.isNotEmpty) {
      // Case (mask: "--00"): "--|12" >> delete >> "--|12" (instead of "-|-12")
      minCursorPosition = acpMask.indexWhere((element) => element);

      // Case (mask: "--00--"): "--12|--" >> add number >> "--12|--" (instead of "--12-|-")
      maxCursorPositionByMask =
          acpMask.reversed.toList().indexWhere((element) => element);
      maxCursorPositionByMask = acpMask.length - maxCursorPositionByMask - 1;
      if (cursorPosition > maxCursorPositionByMask) {
        cursorPosition = maxCursorPositionByMask;
      }
    }

    if (cursorPosition < minCursorPosition) cursorPosition = minCursorPosition;
    if (cursorPosition > maxCursorPosition) cursorPosition = maxCursorPosition;

    return cursorPosition;
  }

  // Where the cursor can fit (only aside a filter key): mask: "--00--0-0" >> can fit ("|") >> "--|0|0|--|0|-|0|"
  List<bool> _allowedCursorPositions([String? mask]) {
    String? currentMask = mask;
    if (currentMask == null || currentMask.isEmpty) return [];
    List<bool> allowCursorPositions = [];

    var splCurrentMask = currentMask.split("");
    String filterKeys = filters.keys.join();
    for (int i = 0; true; i++) {
      if (i == splCurrentMask.length) {
        if (filterKeys.contains(splCurrentMask.last)) {
          allowCursorPositions.add(true);
        } else {
          allowCursorPositions.add(false);
        }
        break;
      }
      if (filterKeys.contains(splCurrentMask[i])) {
        allowCursorPositions.add(true);
      } else if (i == 0) {
        allowCursorPositions.add(false);
      } else if (filterKeys.contains(splCurrentMask[i - 1])) {
        allowCursorPositions.add(true);
      } else {
        allowCursorPositions.add(false);
      }
    }
    return allowCursorPositions;
  }

  void updateText(String text) {
    if (_masks.isNotEmpty) {
      if (selection.baseOffset >= 0) _currentCursor = selection.baseOffset;
      // ! The _masking() method is called even if the user moves only the cursor
      this.text = _masking(text, mask: _currentMask(text));
    } else {
      this.text = text;
    }
  }

  /// Prefer to use [updateText] method to update to a new text instead.
  @override
  set text(String newText) {
    if (super.text != newText) {
      if (_oldText != text) _oldText = text;
      super.text = newText;
      if (cursorToEndWhenUpdate) {
        updateCursor();
      } else {
        _updateCurrentCursor();
      }
      if (currentMask != null) _oldMask = currentMask;
    }
  }

  /// Get the current used mask according to the text.
  String? get currentMask => _currentMask();
  String? _currentMask([String? text]) {
    text ??= this.text;
    if (_masks.isNotEmpty) {
      if (_masks.length == 1) return _masks.first;
      String firstMask = _masks.first;
      int firstMaskFilterKeysLength = 0;
      String filterKeys = filters.keys.join();
      firstMask.split("").forEach((maskChar) {
        if (filterKeys.contains(maskChar)) firstMaskFilterKeysLength++;
      });
      if (text.length <= firstMaskFilterKeysLength) {
        return _masks.first;
      }

      List<String> maskedTextList = [];
      List<String> maskList = [];
      for (var i = 0; i < _masks.length; i++) {
        String mask = _masks[i];
        String maskedText = _masking(text, mask: mask);
        maskedTextList.add(maskedText);
        maskList.add(mask);
        if (maskedText.length < mask.length) break;
      }
      if (maskList.length == 1) return maskList.first;

      String _allNonFilterMask = "";
      for (var mask in _masks) {
        _allNonFilterMask += mask;
      }
      for (var key in filterKeys.split("")) {
        _allNonFilterMask = _allNonFilterMask.replaceAll(key, "");
      }
      final setNonFilterMask = _allNonFilterMask.split("").toSet().toList();
      String lastMasked = maskedTextList.last;
      String penultMasked = maskedTextList[maskedTextList.length - 2];

      if (_allNonFilterMask.isEmpty) {
        if (lastMasked.length > penultMasked.length) {
          return maskList.last;
        }
        return maskList[maskList.length - 2];
      }
      for (int i = 0; i < setNonFilterMask.length; i++) {
        lastMasked = lastMasked.replaceAll(setNonFilterMask[i], "");
        penultMasked = penultMasked.replaceAll(setNonFilterMask[i], "");
      }
      if (lastMasked.length > penultMasked.length) {
        return maskList.last;
      }
      return maskList[maskList.length - 2];
    }
    return null;
  }

  // The mask without the filter keys (mask: "00--00/00" >> it returns "--/")
  String? _nonFilterKeyMask([String? mask]) {
    String? currentMask = mask ?? _currentMask();
    if (currentMask != null) {
      for (var key in filters.keys) {
        currentMask = currentMask?.replaceAll(key, "");
      }
    }
    return currentMask;
  }

  String _masking(String from, {String? mask}) {
    String result = "";
    int fromIndex = 0;
    String? currentMask = mask ?? _currentMask(from);
    if (currentMask == null) return from;
    if (currentMask.isEmpty) return "";

    for (int i = 0; i < currentMask.length; i++) {
      if (fromIndex >= from.length) break;
      if (filters.containsKey(currentMask[i])) {
        final RegExp r = RegExp(filters[currentMask[i]]!);
        if (r.hasMatch(from[fromIndex])) {
          result += from[fromIndex];
        } else {
          i--;
        }
        fromIndex++;
      } else {
        result += currentMask[i];
      }
    }

    String filterKeys = filters.keys.join();
    final maskChars = currentMask.replaceAll(RegExp("[$filterKeys]"), "");
    for (int i = result.length - 1; i >= 0; i--) {
      if (maskChars.contains(result.substring(result.length - 1))) {
        result = result.substring(0, result.length - 1);
      } else {
        break;
      }
    }

    final restMask = currentMask.substring(result.length);
    if (restMask.isNotEmpty) {
      String addResult = "";
      bool containsFilterKey = false;
      final splRestMask = restMask.split("");
      for (var i = 0; i < splRestMask.length; i++) {
        if (!filterKeys.contains(splRestMask[i])) {
          addResult += splRestMask[i];
        } else {
          containsFilterKey = true;
          break;
        }
      }
      if (maskAutoComplete == MaskAutoComplete.quick || !containsFilterKey) {
        result += addResult;
      }
    }

    return result;
  }

  /// Get unmasked text.
  String get unmaskedText {
    String? nonFilterMask = _nonFilterKeyMask();
    String result = text;
    if (nonFilterMask != null && nonFilterMask.isNotEmpty) {
      for (var char in nonFilterMask.split("")) {
        result = result.replaceAll(char, "");
      }
    }
    return result;
  }

  /// Check if the current mask is filled. Returns true if it is not using a mask.
  bool get isFilled {
    var currentMask = _currentMask();
    if (currentMask == null || currentMask.isEmpty) return true;
    return currentMask.length == text.length;
  }
}
