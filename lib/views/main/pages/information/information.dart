import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/views/main/pages/information/clipboards.dart';
import 'package:campus_motorsport/views/main/pages/information/create_clipboard.dart';
import 'package:campus_motorsport/views/main/pages/information/general_information.dart';
import 'package:campus_motorsport/widgets/infomation/clipboards_context.dart';
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
      case InformationPage.clipboards:
        if (offlineMode) {
          return const SizedBox();
        }
        return const Clipboards();
      case InformationPage.addClipboard:
        if (offlineMode) {
          return const SizedBox();
        }
        return const CreateClipboard();
    }
  }
}

class InformationViewSecondary extends StatelessWidget {
  const InformationViewSecondary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = context.read<CurrentUser>().user?.isAdmin ?? false;
    final InformationViewProvider viewProvider =
        context.watch<InformationViewProvider>();

    final List<Widget> children = InformationPage.values.map((page) {
      if ((page == InformationPage.clipboards ||
              page == InformationPage.addClipboard) &&
          viewProvider.offlineMode) {
        return const SizedBox();
      }
      if (!isAdmin && page == InformationPage.addClipboard) {
        return const SizedBox();
      }

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

class InformationContext extends StatelessWidget {
  const InformationContext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InformationViewProvider viewProvider =
        context.watch<InformationViewProvider>();

    switch (viewProvider.currentPage) {
      case InformationPage.clipboards:
        return const ClipBoardContext();
      default:
        return const SizedBox();
    }
  }
}
