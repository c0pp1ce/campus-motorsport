import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/state_updates.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllUpdates extends StatefulWidget {
  const AllUpdates({Key? key}) : super(key: key);

  @override
  _AllUpdatesState createState() => _AllUpdatesState();
}

class _AllUpdatesState extends State<AllUpdates> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    /// Some error occurred.
    if (viewProvider.currentlyOpen == null) {
      ExpandedAppBar(
        appbarTitle: Text('Fehler beim Laden.'),
        offsetBeforeTitleShown: 0,
        appbarChild: const SizedBox(),
      );
    }

    return ExpandedAppBar(
      onRefresh: viewProvider.reloadCurrentlyOpen,
      loadingListener: (value) {
        setState(() {
          loading = value;
        });
      },
      appbarTitle: const Text('Alle Wartungen'),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Alle Wartungen',
        ),
      ),
      offsetBeforeTitleShown: 60,
      body: loading
          ? const LoadingList()
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SizeConfig.basePadding,
              ),
              child: StateUpdates(
                titlesBasedOfDate: true,
                updates: viewProvider.currentlyOpen!.updates,
              ),
            ),
    );
  }
}
