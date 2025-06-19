import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:dynamic_widget/dynamic_widget/utils.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidgetParser extends WidgetParser {
  @override
  String get widgetName => "TextFormField";

  @override
  Type get widgetType => TextFormField;

  @override
  Widget parse(
    Map<String, dynamic> map,
    BuildContext buildContext,
    ClickListener? listener,
  ) {
    // Build InputDecoration if provided
    InputDecoration? decoration;
    if (map['decoration'] is Map<String, dynamic>) {
      final decorMap = map['decoration'] as Map<String, dynamic>;
      decoration = InputDecoration(
        labelText: decorMap['labelText'] as String?,
        hintText: decorMap['hintText'] as String?,
      );
    }

    // Read basic properties
    final initialValue = map['initialValue'] as String?;
    final obscureText = map['obscureText'] as bool? ?? false;

    // Map keyboardType string to TextInputType
    TextInputType keyboardType = TextInputType.text;
    if (map['keyboardType'] is String) {
      switch (map['keyboardType']) {
        case 'multiline':
          keyboardType = TextInputType.multiline;
          break;
        case 'number':
          keyboardType = TextInputType.number;
          break;
        case 'phone':
          keyboardType = TextInputType.phone;
          break;
        case 'datetime':
          keyboardType = TextInputType.datetime;
          break;
        case 'emailAddress':
          keyboardType = TextInputType.emailAddress;
          break;
        case 'url':
          keyboardType = TextInputType.url;
          break;
      }
    }

    return TextFormField(
      initialValue: initialValue,
      decoration: decoration,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }

  @override
  Map<String, dynamic>? export(Widget? widget, BuildContext? buildContext) {
    // We can’t read obscureText/decoration/etc. back out of TextFormField,
    // because those properties aren’t exposed. So we return only the type:
    if (widget is TextFormField) {
      return <String, dynamic>{'type': widgetName};
    }
    return null;
  }
}
