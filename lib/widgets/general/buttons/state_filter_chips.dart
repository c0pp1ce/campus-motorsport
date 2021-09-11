import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/state_filter_provider_mixin.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/current_state.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Provides state filters.
///
/// Currently only works with [StateFilterProviderMixin].
class StateFilterChips extends StatelessWidget {
  const StateFilterChips({
    required this.filterProvider,
    Key? key,
  }) : super(key: key);

  final StateFilterProviderMixin filterProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Status Filter',
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.start,
        ),
        _buildFilterChips(context),
        const Divider(
          thickness: 1.2,
          indent: SizeConfig.basePadding,
          endIndent: SizeConfig.basePadding,
          height: SizeConfig.basePadding * 2,
        ),
        _buildInfo(
          context,
          'Filter die Komponenten basierend auf ihrem Status.',
          LineIcons.filter,
        ),
        const Divider(
          thickness: 1.2,
          indent: SizeConfig.basePadding,
          endIndent: SizeConfig.basePadding,
          height: SizeConfig.basePadding * 2,
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ComponentState.values.map((state) {
        final bool selected = filterProvider.allowedStates.contains(state);
        return FilterChip(
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          label: Text(
            state.name,
            style: getChipTextStyle(state, selected, context),
          ),
          selectedColor: stateColor(state).withOpacity(1),
          elevation: SizeConfig.baseBackgroundElevation,
          selected: selected,
          onSelected: (select) {
            if (select) {
              filterProvider.allowState(state);
            } else {
              filterProvider.hideState(state);
            }
          },
        );
      }).toList(),
    );
  }

  TextStyle? getChipTextStyle(
    ComponentState state,
    bool selected,
    BuildContext context,
  ) {
    return Theme.of(context).textTheme.bodyText2?.copyWith(
        color: selected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface);
  }

  Color stateColor(ComponentState state) {
    switch (state) {
      case ComponentState.bad:
        return ColorServices.brighten(CurrentState.badState, 35);
      case ComponentState.ok:
        return ColorServices.brighten(CurrentState.okState, 35);
      case ComponentState.newComponent:
        return ColorServices.brighten(CurrentState.newState, 25);
    }
  }

  Widget _buildInfo(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 65,
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
