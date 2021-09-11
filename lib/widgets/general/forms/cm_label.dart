import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:flutter/material.dart';

class CMLabel extends StatelessWidget {
  const CMLabel({
    this.darken = false,
    required this.label,
    Key? key,
  }) : super(key: key);

  final String label;
  final bool darken;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            fontSize: 16,
            color: darken
                ? ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    VehicleComponent.darkenTextBy,
                  )
                : null,
          ),
    );
  }
}
