import 'package:flutter/material.dart';
import 'package:wecare/models/user.dart';

final List<Map<String, String>> UserRoles = [
  {'name': 'Caregiver', 'value': UserRole.caregiver.toString()},
  {'name': 'Recipient', 'value': UserRole.recipient.toString()},
  {'name': 'Care Manager', 'value': UserRole.caremanager.toString()},
  {'name': 'Practitioner', 'value': UserRole.practitioner.toString()},
];

class PropsRoleItem extends FormField<String> {
  PropsRoleItem({
    String? initialValue,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    IconData? icon,
    String? label,
    bool? enabled,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (state) {
              return _PropsRoleFormItem(
                  state: state,
                  onChanged: onChanged,
                  icon: icon,
                  label: label,
                  enabled: enabled);
            });
}

class _PropsRoleFormItem extends StatefulWidget {
  final FormFieldState<String> state;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;
  final bool? enabled;

  _PropsRoleFormItem(
      {required this.state,
      required this.onChanged,
      this.icon,
      this.label,
      this.enabled});

  @override
  _PropsRoleFormItemState createState() => _PropsRoleFormItemState(state);
}

class _PropsRoleFormItemState extends State<_PropsRoleFormItem> {
  FormFieldState<String> state;
  Map<String, String>? value;

  _PropsRoleFormItemState(this.state);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsetsDirectional.all(12.0),
        child: Row(children: [
          Icon(widget.icon),
          SizedBox(width: 16),
          Expanded(
            child: Container(
                child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: widget.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: DropdownButton(
                      value: value,
                      onChanged: (Map<String, String>? newValue) {
                        state.setValue(newValue!['value']);
                        setState(() {
                          value = newValue;
                        });
                      },
                      items: UserRoles.map((role) {
                        return DropdownMenuItem(
                            value: role,
                            child: Row(children: [
                              Text(role['name']!),
                            ]));
                      }).toList(),
                    ))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    value = UserRoles.firstWhere((e) => e['value'] == state.value,
        orElse: () => UserRoles[0]);
    state.setValue(value!['value']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(_PropsRoleFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
