import 'package:campus_motorsport/models/component_containers/event.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/add_event.dart';
import 'package:campus_motorsport/widgets/component_containers/events_list.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    if (viewProvider.currentlyOpen == null) {
      return const ExpandedAppBar(
        appbarTitle: Text('Fehler beim Laden.'),
        offsetBeforeTitleShown: 60,
        appbarChild: Center(
          child: Text('Fehler beim Laden.'),
        ),
      );
    }

    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;

    return ExpandedAppBar(
      appbarTitle: Text(
        'Events',
        style: Theme.of(context).textTheme.headline6,
      ),
      offsetBeforeTitleShown: 50,
      onRefresh: viewProvider.reloadCurrentlyOpen,
      loadingListener: (value) {
        setState(() {
          loading = value;
        });
      },
      actions: isAdmin && !loading
          ? [_buildAddEventButton(context, viewProvider)]
          : null,
      appbarChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const ExpandedTitle(title: 'Events'),
          Text(
            viewProvider.currentlyOpen!.name,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
          ),
        ],
      ),
      body: loading
          ? LoadingList()
          : Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SizeConfig.basePadding),
              child: EventsList(),
            ),
    );
  }

  Widget _buildAddEventButton(
      BuildContext context, CCViewProvider viewProvider) {
    return IconButton(
      onPressed: () async {
        final Event? event = await _showAddEventDialog(context);
        if (event != null) {
          setState(() {
            loading = true;
          });
          final bool success = await CrudCompContainer().addEvent(
            docId: viewProvider.currentlyOpen!.id!,
            event: event,
          );
          if (!success) {
            _showErrorDialog();
          } else {
            await viewProvider.reloadCurrentlyOpen();
          }
          setState(() {
            loading = false;
          });
        }
      },
      icon: Icon(
        LineIcons.plus,
      ),
      splashRadius: SizeConfig.iconButtonSplashRadius,
    );
  }

  Future<Event?> _showAddEventDialog(BuildContext context) {
    return showModalBottomSheet<Event?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: SizeConfig.baseBackgroundElevation,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.baseBorderRadius),
          topRight: Radius.circular(SizeConfig.baseBorderRadius),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(
            SizeConfig.basePadding,
          ),
          child: AddEvent(
            currentUser: context.read<CurrentUser>().user?.name ?? 'Unbekannt',
            onSaved: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: 'Bitte überprüfe deine Verbindung.',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'VERSTANDEN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }
}
