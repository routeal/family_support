import 'package:flutter/material.dart';
import 'package:wecare/models/user.dart';

final List<Map<String, String>> careLevels = [
  {
    'name': 'Not Available',
    'value': CareLevel.none.toString(),
  },
  {
    'name': 'Care Level 1',
    'value': CareLevel.one.toString(),
  },
  {
    'name': 'Care Level 2',
    'value': CareLevel.two.toString(),
  },
  {
    'name': 'Care Level 3',
    'value': CareLevel.three.toString(),
  },
  {
    'name': 'Care Level 4',
    'value': CareLevel.four.toString(),
  },
  {
    'name': 'Care Level 5',
    'value': CareLevel.five.toString(),
  },
];

class PropsCareLevelItem extends FormField<String> {
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;
  PropsCareLevelItem({
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
              return (state as _PropsCareLevelFormState).construct();
            });

  @override
  FormFieldState<String> createState() {
    return _PropsCareLevelFormState(
        icon: icon, label: label, onChanged: onChanged);
  }
}

class _PropsCareLevelFormState extends FormFieldState<String> {
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;

  Map<String, String>? item;

  _PropsCareLevelFormState({
    this.onChanged,
    this.icon,
    this.label,
  });

  Widget construct() {
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
                          items: careLevels.map((level) {
                            return DropdownMenuItem(
                                value: level,
                                child: Row(children: [
                                  Text(level['name']!),
                                ]));
                          }).toList(),
                        )))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    item = careLevels.firstWhere((e) => e['value'] == value,
        orElse: () => careLevels[0]);
    setValue(item!['value']);
  }
}
