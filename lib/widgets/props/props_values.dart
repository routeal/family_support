import 'package:flutter/material.dart';

enum PropsType { InputField, Photo, Error, Color }

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
    required this.onSaved,
    this.validator,
    this.onChanged,
    this.icon,
    this.enabled = true,
  });
}

abstract class PropsValues {
  // title in AppBar
  String? _title;
  String? get title => _title;
  set title(String? str) {
    _title = str;
  }

  // label string for save button
  String? _saveButtonLabel;
  String? get saveButtonLabel => _saveButtonLabel;
  set saveButtonLabel(String? str) {
    _saveButtonLabel = str;
  }

  // label string for logout button, if it's empty, logout won't be created
  String? _logoutButtonLabel;
  String? get logoutButtonLabel => _logoutButtonLabel;
  set logoutButtonLabel(String? str) {
    _logoutButtonLabel = str;
  }

  // form key for save and validate
  GlobalKey<FormState>? _formKey;
  GlobalKey<FormState>? get key => _formKey;
  set key(GlobalKey<FormState>? k) {
    _formKey = k;
  }

  bool get dirty;

  List<PropsValueItem> items();

  void submit(BuildContext context);
}
