import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';

class ListSubHeader extends StatelessWidget {
  const ListSubHeader({
    required this.header,
    Key? key,
  }) : super(key: key);

  final String header;

  @override
  Widget build(BuildContext context) {
    return Text(
      header,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            color: ColorServices.darken(
              Theme.of(context).colorScheme.onSurface,
              SizeConfig.darkenTextColorBy,
            ),
          ),
    );
  }
}
