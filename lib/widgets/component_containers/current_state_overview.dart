import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Simple overview of the current state of a vehicle/stock.
class CurrentStateOverview extends StatelessWidget {
  const CurrentStateOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ComponentContainer componentContainer =
        context.watch<CCViewProvider>().currentlyOpen!;
    final List<int> counts = _calculateCounts(componentContainer);

    return Column(
      children: <Widget>[
        Text(
          'Zustandsübersicht',
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(
          height: SizeConfig.basePadding * 2,
        ),
        SimpleCard(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _buildCounter(
                    'Nie gewartet',
                    Colors.grey,
                    counts[0],
                    context,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildCounter(
                    'n.i.O.',
                    Colors.redAccent,
                    counts[1],
                    context,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildCounter(
                    'i.O.',
                    Colors.yellowAccent,
                    counts[2],
                    context,
                  ),
                ),
                _buildDivider(context),
                Expanded(
                  child: _buildCounter(
                    'Neu',
                    Colors.greenAccent,
                    counts[3],
                    context,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounter(
    String title,
    Color color,
    int count,
    BuildContext context,
  ) {
    return SizedBox(
      height: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.circle,
                color: color,
              ),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: color,
                    ),
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(
            height: SizeConfig.basePadding / 2,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return VerticalDivider(
      color: ColorServices.darken(
        Theme.of(context).colorScheme.onSurface,
        SizeConfig.darkenTextColorBy,
      ),
      thickness: 1.2,
      width: 10,
      indent: 10,
      endIndent: 10,
    );
  }

  List<int> _calculateCounts(ComponentContainer componentContainer) {
    final List<int> results = List.filled(4, 0);
    results[0] = componentContainer.components.length -
        componentContainer.currentState.length;

    for (final update in componentContainer.currentState) {
      switch (update.component.state) {
        case ComponentStates.bad:
          results[1]++;
          break;
        case ComponentStates.ok:
          results[2]++;
          break;
        case ComponentStates.newComponent:
          results[3]++;
          break;
      }
    }

    return results;
  }
}
