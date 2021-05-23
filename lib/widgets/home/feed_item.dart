import 'package:campus_motorsport/widgets/general/style/simple_card.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

enum FeedItemType {
  maintenance,
  event,
}

class FeedItem extends StatelessWidget {
  final FeedItemType type;
  const FeedItem({
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SimpleCard(
        elevation: 5,
        color: ElevationOverlay.applyOverlay(
            context, Theme.of(context).colorScheme.surface, 10),
        child: ListTile(
          leading: Icon(
            type == FeedItemType.maintenance
                ? LineIcons.tools
                : LineIcons.calendar,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (type == FeedItemType.maintenance) Text("Wartung"),
                  if (type == FeedItemType.event) Text("Event"),
                  const SizedBox(
                    height: 10,
                  ),
                  if (type == FeedItemType.maintenance)
                    Text(
                      "5 Teile",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  if (type == FeedItemType.event)
                    Text(
                      "Testfahrt",
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  Text(
                    "Lennart Koloska",
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "BLN-01",
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  Text(
                    "Vor 3 Tagen",
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  SizedBox(
                    height: 40,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      child: Text("Details".toUpperCase()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
