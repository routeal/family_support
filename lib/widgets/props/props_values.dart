import 'package:flutter/material.dart';

enum PropsType { InputField, Photo, Error, Color, Role, CareLevel }

class PropsValueItem {
  PropsType type;
  String? init;
  String? label;
  FormFieldSetter<String>? onSaved;
  FormFieldValidator<String>? validator;
  ValueChanged<String>? onChanged;
  IconData? icon;
  bool enabled;

  PropsValueItem({
    required this.type,
    this.init,
    this.label,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.icon,
    this.enabled = true,
  });
}

abstract class PropsValues {
  // title in AppBar
  String? title;

  // label string for logout button, if it's empty, logout won't be created
  String? logoutButtonLabel;

  PropsValues({
    this.title,
    this.logoutButtonLabel,
  });

  // label string for save button
  String? saveButtonLabel;

  // form key for save and validate
  GlobalKey<FormState>? key;

  bool get dirty;

  List<PropsValueItem> items();

  void submit(BuildContext context);
}
