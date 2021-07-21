import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:flutter/material.dart';

class CMDropDownMenu extends StatefulWidget {
  const CMDropDownMenu({
    required this.values,
    required this.onSelect,
    required this.label,
    this.enabled = true,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  final List<String> values;
  final void Function(String?) onSelect;
  final bool enabled;
  final String label;
  final String? initialValue;

  @override
  CMDropDownMenuState createState() => CMDropDownMenuState();
}

class CMDropDownMenuState extends State<CMDropDownMenu> {
  String? currentValue;

  @override
  void initState() {
    currentValue = widget.initialValue;
    super.initState();
  }

  void reset() {
    setState(() {
      currentValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: currentValue,
      style: Theme.of(context).textTheme.subtitle1,
      iconDisabledColor: Colors.transparent,
      onChanged: !widget.enabled
          ? null
          : (value) {
              setState(() {
                currentValue = value as String?;
                widget.onSelect(value);
              });
            },
      validator: (value) =>
          Validators().validateNotEmpty(value as String?, 'Auswahl'),
      items: widget.values.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: widget.label,
        enabled: widget.enabled,
        enabledBorder: OutlineInputBorder(
          gapPadding: 3.0,
          borderSide: BorderSide(
            color: ColorServices.brighten(
                Theme.of(context).colorScheme.surface, 40),
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          gapPadding: 3.0,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        errorBorder: OutlineInputBorder(
          gapPadding: 3.0,
          borderSide: BorderSide(
            color:
                ColorServices.darken(Theme.of(context).colorScheme.error, 60),
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}
