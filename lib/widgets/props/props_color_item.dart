import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wecare/utils/colors.dart';

class PropsColorItem extends FormField<String> {
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;
  PropsColorItem({
    String? initialValue,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    bool? enabled,
    this.onChanged,
    this.icon,
    this.label,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<String> state) {
              return state.build(state.context);
            });

  @override
  FormFieldState<String> createState() {
    return _PropsColorFormItemState(
        icon: icon, label: label, onChanged: onChanged);
  }
}

class _PropsColorFormItemState extends FormFieldState<String> {
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;

  Map<String, String>? item;

  _PropsColorFormItemState({
    this.onChanged,
    this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsetsDirectional.all(12.0),
        child: Row(children: [
          Icon(icon),
          SizedBox(width: 16),
          Expanded(
            child: Container(
                child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: IgnorePointer(
                        ignoring: !widget.enabled,
                        child: DropdownButton(
                          value: item,
                          onChanged: (Map<String, String>? newItem) {
                            setValue(newItem!['value']);
                            if (onChanged != null) {
                              onChanged!(newItem['value']!);
                            }
                            setState(() {
                              item = newItem;
                            });
                          },
                          items: FavoriteColors.map((color) {
                            return DropdownMenuItem(
                                value: color,
                                child: Row(children: [
                                  Container(
                                    color: HexColor(color['value']!),
                                    child: SizedBox(
                                      width: 120,
                                      height: 32,
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Text(color['name']!),
                                ]));
                          }).toList(),
                        )))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    item = FavoriteColors.firstWhere((e) => e['value'] == value,
        orElse: () => FavoriteColors[Random().nextInt(FavoriteColors.length)]);
    setValue(item!['value']);
  }
}
