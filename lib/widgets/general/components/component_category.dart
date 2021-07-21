import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:flutter/material.dart';

class ComponentCategory extends StatelessWidget {
  const ComponentCategory({
    required this.onSaved,
    this.enabled = true,
    this.dropDownKey,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  final void Function(String?) onSaved;
  final bool enabled;
  final GlobalKey<CMDropDownMenuState>? dropDownKey;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        CMDropDownMenu(
          initialValue: initialValue,
          key: dropDownKey,
          label: 'Kategorie',
          enabled: enabled,
          values: ComponentCategories.values.map((e) => e.name).toList(),
          onSelect: onSaved,
        ),
      ],
    );
  }
}
