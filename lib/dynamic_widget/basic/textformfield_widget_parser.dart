// lib/dynamic_widget/basic/textformfield_widget_parser.dart
import 'package:flutter/material.dart';
import 'package:dynamic_widget/dynamic_widget.dart';

/// Simple in-memory controller cache so different dynamic widgets (or pages)
/// can share a controller by id.
class _ControllerStore {
  static final _cache = <String, TextEditingController>{};

  static TextEditingController get(String id, [String? initial]) {
    return _cache[id] ??= TextEditingController(text: initial ?? '');
  }
}

class TextFormFieldWidgetParser extends WidgetParser {
  @override
  String get widgetName => 'TextFormField';

  @override
  Type get widgetType => TextFormField;

  @override
  Widget parse(
      Map<String, dynamic> map,
      BuildContext buildContext,
      ClickListener? listener,
      ) {
    // ── 1. DECORATION ──────────────────────────────────────────────────────────
    InputDecoration? decoration;
    if (map['decoration'] is Map<String, dynamic>) {
      final d = map['decoration'] as Map<String, dynamic>;
      decoration = InputDecoration(
        labelText: d['labelText'] as String?,
        hintText: d['hintText'] as String?,
      );
    }

    // ── 2. SIMPLE PROPS ───────────────────────────────────────────────────────
    final initialValue = map['initialValue'] as String?;
    final obscureText  = map['obscureText']  as bool? ?? false;

    // keyboardType from string → enum
    TextInputType keyboardType = TextInputType.text;
    switch (map['keyboardType']) {
      case 'multiline':    keyboardType = TextInputType.multiline;   break;
      case 'number':       keyboardType = TextInputType.number;      break;
      case 'phone':        keyboardType = TextInputType.phone;       break;
      case 'datetime':     keyboardType = TextInputType.datetime;    break;
      case 'emailAddress': keyboardType = TextInputType.emailAddress;break;
      case 'url':          keyboardType = TextInputType.url;         break;
    }

    // ── 3. CONTROLLER SUPPORT ────────────────────────────────────────────────
    TextEditingController? controller;
    if (map['controllerId'] is String) {
      controller = _ControllerStore.get(map['controllerId'], initialValue);
    }

    // ── 4. EVENT SUPPORT (onTap / onChanged) ─────────────────────────────────
    final tapEvent      = map['onTap']      as String?;
    final changedEvent  = map['onChanged']  as String?;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null, // avoid conflict
      decoration: decoration,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: tapEvent == null
          ? null
          : () => listener?.onClicked(tapEvent),
      onChanged: changedEvent == null
          ? null
          : (v) => listener?.onClicked(changedEvent),
    );
  }

  @override
  Map<String, dynamic>? export(Widget? widget, BuildContext? context) {
    // We still can’t read runtime props back; just emit the type.
    if (widget is TextFormField) return {'type': widgetName};
    return null;
  }
}
