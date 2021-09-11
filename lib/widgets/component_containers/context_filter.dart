import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/category_filter_chips.dart';
import 'package:campus_motorsport/widgets/general/buttons/state_filter_chips.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

/// Context menu for all component-container pages which need one.
/// Provides filters for component categories and states.
class ContextFilter extends StatelessWidget {
  const ContextFilter({
    this.showStateFilter = true,
    this.currentState = false,
    Key? key,
  }) : super(key: key);

  final bool showStateFilter;
  final bool currentState;

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();
    return ContextDrawer(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CategoryFilterChips(filterProvider: viewProvider),
              if (showStateFilter)
                StateFilterChips(filterProvider: viewProvider),
              if (currentState)
                _buildInfo(
                  context,
                  'Filter haben keine Einfluss auf nie gewartete Komponenten.',
                  LineIcons.infoCircle,
                ),
            ],
          ),
        ),
      ),
    );
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
