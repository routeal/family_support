import 'package:flutter/material.dart';
import 'package:wecare/utils/colors.dart';

class PropsColorItem extends FormField<String> {
  PropsColorItem({
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
              return _PropsColorFormItem(
                  state: state,
                  onChanged: onChanged,
                  icon: icon,
                  label: label,
                  enabled: enabled);
            });
}

class _PropsColorFormItem extends StatefulWidget {
  final FormFieldState<String> state;
  ValueChanged<String>? onChanged;
  IconData? icon;
  String? label;
  bool? enabled;

  _PropsColorFormItem(
      {required this.state,
      required this.onChanged,
      this.icon,
      this.label,
      this.enabled});

  @override
  _PropsColorFormItemState createState() => _PropsColorFormItemState(state);
}

class _PropsColorFormItemState extends State<_PropsColorFormItem> {
  FormFieldState<String> state;
  Map<String, String>? value;

  _PropsColorFormItemState(this.state);

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
                    ))),
          )
        ]));
  }

  @override
  void initState() {
    super.initState();
    value = FavoriteColors.firstWhere((e) => e['value'] == state.value,
        orElse: () => FavoriteColors[0]);
    state.setValue(value!['value']);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(_PropsColorFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
