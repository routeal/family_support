import 'package:flutter/material.dart';
import 'package:wecare/models/user.dart';

class PropsCareLevelItem extends FormField<String> {
  PropsCareLevelItem({
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
              return _PropsCareLevelFormItem(
                  state: state,
                  onChanged: onChanged,
                  icon: icon,
                  label: label,
                  enabled: enabled);
            });
}

class _PropsCareLevelFormItem extends StatefulWidget {
  final FormFieldState<String> state;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final String? label;
  final bool? enabled;

  _PropsCareLevelFormItem(
      {required this.state,
      required this.onChanged,
      this.icon,
      this.label,
      this.enabled});

  @override
  _PropsCareLevelFormItemState createState() => _PropsCareLevelFormItemState(state);
}

class _PropsCareLevelFormItemState extends State<_PropsCareLevelFormItem> {
  FormFieldState<String> state;
  Map<String, String>? value;

  _PropsCareLevelFormItemState(this.state);

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
                      items: CareLevels.map((level) {
                        return DropdownMenuItem(
                            value: level,
                            child: Row(children: [
                              Text(level['name']!),
                            ]));
                      }).toList(),
                    ))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    value = CareLevels.firstWhere((e) => e['value'] == state.value,
        orElse: () => CareLevels[0]);
    state.setValue(value!['value']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(_PropsCareLevelFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
