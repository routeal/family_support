import 'package:flutter/material.dart';
import 'package:wecare/models/user.dart';

final List<Map<String, String>> userRoles = [
  {'name': 'Caregiver', 'value': UserRole.caregiver.toString()},
  {'name': 'Recipient', 'value': UserRole.recipient.toString()},
  {'name': 'Care Manager', 'value': UserRole.caremanager.toString()},
  {'name': 'Practitioner', 'value': UserRole.practitioner.toString()},
];

class PropsRoleItem extends FormField<String> {
  final IconData? icon;
  final String? label;
  final ValueChanged<String>? onChanged;

  PropsRoleItem({
    String? initialValue,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    this.onChanged,
    this.icon,
    this.label,
    bool? enabled,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<String> state) {
              return state.build(state.context);
            });

  @override
  FormFieldState<String> createState() {
    return _PropsRoleFormItemState(
        icon: icon, label: label, onChanged: onChanged);
  }
}

class _PropsRoleFormItemState extends FormFieldState<String> {
  Map<String, String>? item;

  final IconData? icon;
  final String? label;
  final ValueChanged<String>? onChanged;

  _PropsRoleFormItemState({this.icon, this.label, this.onChanged});

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
                          items: userRoles.map((role) {
                            return DropdownMenuItem(
                                value: role,
                                child: Row(children: [
                                  Text(role['name']!),
                                ]));
                          }).toList(),
                        )))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    item = userRoles.firstWhere((e) => e['value'] == value,
        orElse: () => userRoles[0]);
    setValue(item!['value']);
  }
}
