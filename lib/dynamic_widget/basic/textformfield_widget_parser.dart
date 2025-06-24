// lib/dynamic_widget/basic/textformfield_widget_parser.dart
import 'package:flutter/material.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:dynamic_widget/dynamic_widget/utils.dart'; // for color & padding helpers

class TextFormFieldWidgetParser extends WidgetParser {
  @override
  String get widgetName => 'TextFormField';
  @override
  Type  get widgetType => TextFormField;

  // ────────────────────────────────────────────────────────────────
  // Helper to convert the decoration map into an InputDecoration
  InputDecoration _buildDecoration(Map<String, dynamic> d) {
    // 1. Basic strings
    final labelText  = d['labelText']  as String?;
    final hintText   = d['hintText']   as String?;
    final helperText = d['helperText'] as String?;
    final errorText  = d['errorText']  as String?;

    // 2. Fill color
    final fillColor  = d['fillColor'] != null
        ? parseHexColor(d['fillColor'])
        : null;
    final filled = fillColor != null;

    // 3. Border style
    final String borderType = (d['border'] as String? ?? 'outline').toLowerCase();
    InputBorder _outline([Color? c]) =>
        OutlineInputBorder(borderSide: BorderSide(color: c ?? Colors.grey));
    InputBorder _underline([Color? c]) =>
        UnderlineInputBorder(borderSide: BorderSide(color: c ?? Colors.grey));

    InputBorder? border;
    switch (borderType) {
      case 'none':     border = InputBorder.none; break;
      case 'underline':border = _underline();     break;
      default:         border = _outline();       break;
    }

    // 4. Content padding
    final EdgeInsets? padding =
    d['contentPadding'] is String ? parseEdgeInsetsGeometry(d['contentPadding']) as EdgeInsets : null;

    // 5. Prefix / suffix icons (simple Material icon names)
    // IconData? _iconData(String? name) =>
    //     name == null ? null : Icons.tryParse(name);
    // final prefixIcon = _iconData(d['prefixIconData']);
    // final suffixIcon = _iconData(d['suffixIconData']);

    return InputDecoration(
      labelText:   labelText,
      hintText:    hintText,
      helperText:  helperText,
      errorText:   errorText,
      fillColor:   fillColor,
      filled:      filled,
      contentPadding: padding,
      border:          border,
      enabledBorder:   border,
      focusedBorder:   border,
      // prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      // suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
    );
  }
  // ────────────────────────────────────────────────────────────────

  @override
  Widget parse(
      Map<String, dynamic> map,
      BuildContext context,
      ClickListener? listener,
      ) {
    // DECORATION
    InputDecoration? decoration;
    if (map['decoration'] is Map<String, dynamic>) {
      decoration = _buildDecoration(map['decoration']);
    }

    // SIMPLE PROPS
    final initialValue = map['initialValue'] as String?;
    final obscureText  = map['obscureText'] as bool? ?? false;

    // keyboardType
    TextInputType keyboardType = TextInputType.text;
    switch (map['keyboardType']) {
      case 'multiline':    keyboardType = TextInputType.multiline;   break;
      case 'number':       keyboardType = TextInputType.number;      break;
      case 'phone':        keyboardType = TextInputType.phone;       break;
      case 'datetime':     keyboardType = TextInputType.datetime;    break;
      case 'emailAddress': keyboardType = TextInputType.emailAddress;break;
      case 'url':          keyboardType = TextInputType.url;         break;
    }

    // CONTROLLER (optional, stays same as earlier example)
    TextEditingController? controller;
    if (map['controllerId'] is String) {
      controller = _ControllerStore.get(map['controllerId'], initialValue);
    }

    // EVENTS (optional)
    final tapEvent     = map['onTap']     as String?;
    final changeEvent  = map['onChanged'] as String?;

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: decoration,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onTap: tapEvent == null
          ? null
          : () => listener?.onClicked(tapEvent),
      onChanged: changeEvent == null
          ? null
          : (v) => listener?.onClicked('$changeEvent:$v'),
    );
  }

  @override
  Map<String, dynamic>? export(Widget? widget, BuildContext? ctx) =>
      widget is TextFormField ? {'type': widgetName} : null;
}

// ── Simple controller cache (same as earlier) ─────────────────────
class _ControllerStore {
  static final _cache = <String, TextEditingController>{};
  static TextEditingController get(String id, [String? init]) =>
      _cache[id] ??= TextEditingController(text: init ?? '');
}
