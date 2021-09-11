import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:flutter/material.dart';

import 'loading_item.dart';

class LoadingList extends StatelessWidget {
  const LoadingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemExtent: 140,
      itemBuilder: (context, index) {
        return const LoadingItem(
          child: SimpleCard(
            margin: EdgeInsets.all(SizeConfig.basePadding),
            child: SizedBox(),
          ),
        );
      },
    );
  }
}
