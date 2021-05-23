import 'package:campus_motorsport/widgets/home/feed_item.dart';
import 'package:flutter/material.dart';

class Feed extends StatelessWidget {
  const Feed({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Text(
            "Neueste Aktivitäten",
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.start,
          ),
        ),
        ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return FeedItem(
              type: (index > 0 && index % 5 == 0)
                  ? FeedItemType.event
                  : FeedItemType.maintenance,
            );
          },
        ),
      ],
    );
  }
}
