import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/views/main/pages/information/general_information.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InformationView extends StatelessWidget {
  const InformationView({
    this.offlineMode = false,
    Key? key,
  }) : super(key: key);

  final bool offlineMode;

  @override
  Widget build(BuildContext context) {
    final InformationViewProvider viewProvider =
        context.watch<InformationViewProvider>();

    switch (viewProvider.currentPage) {
      case InformationPage.generalInfo:
        return GeneralInformation(
          offlineMode: offlineMode,
        );
    }
  }
}

class InformationViewSecondary extends StatelessWidget {
  const InformationViewSecondary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InformationViewProvider viewProvider =
        context.watch<InformationViewProvider>();

    final List<Widget> children = InformationPage.values.map((page) {
      return ListTile(
        onTap: () {
          viewProvider.switchTo(page);
        },
        title: Text(
          page.pageName,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: viewProvider.currentPage == page
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
        ),
      );
    }).toList();

    return Material(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: children,
      ),
    );
  }
}
