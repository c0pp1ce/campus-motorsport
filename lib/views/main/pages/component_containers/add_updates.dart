import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/component_selection_pre_update.dart';
import 'package:campus_motorsport/widgets/component_containers/update_components.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

/// View where a user can select a component and add an update to the container.
class AddUpdates extends StatefulWidget {
  const AddUpdates({Key? key}) : super(key: key);

  @override
  _AddUpdatesState createState() => _AddUpdatesState();
}

class _AddUpdatesState extends State<AddUpdates> {
  final List<BaseComponent> selectedForUpdate = [];
  bool selectionFinished = false;
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

    final ComponentContainer currentContainer = viewProvider.currentlyOpen!;
    final List<BaseComponent> allComponents =
        context.watch<ComponentsProvider>().components;
    final List<BaseComponent> containerComponents = allComponents
        .where((element) => currentContainer.components.contains(element.id))
        .toList();

    return ExpandedAppBar(
      showOnSiteIndicator: !selectionFinished,
      onRefresh: viewProvider.reloadCurrentlyOpen,
      loadingListener: (value) {
        setState(() {
          loading = value;
        });
      },
      offsetBeforeTitleShown: 50,
      appbarTitle: Text(
        !selectionFinished ? 'Komponenten auswählen' : 'Wartungen eintragen',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ExpandedTitle(
            title: !selectionFinished
                ? 'Komponenten auswählen'
                : 'Wartungen eintragen',
          ),
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
      actions: _buildActions(context),
      body: loading
          ? LoadingList()
          : !selectionFinished
              ? ComponentSelectionPreUpdate(
                  components: containerComponents
                      .where((element) => viewProvider.allowedCategories
                          .contains(element.category))
                      .toList(),
                  getSelected: (component) =>
                      selectedForUpdate.contains(component),
                  doneButton: _buildNextButton(context),
                  onSelect: (component) {
                    setState(() {
                      if (selectedForUpdate.contains(component)) {
                        selectedForUpdate.remove(component);
                      } else {
                        selectedForUpdate.add(component);
                      }
                    });
                  },
                )
              : UpdateComponents(
                  // key: ValueKey('updateComponents${currentContainer.id}'),
                  currentContainer: currentContainer,
                  selectedComponents: selectedForUpdate,
                  loadingListener: _loadingListener,
                  successListener: _successListener,
                ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: loading ? null : _reset,
        icon: Icon(LineIcons.trash),
        splashRadius: SizeConfig.iconButtonSplashRadius,
        color: ColorServices.darken(
          Theme.of(context).colorScheme.secondary,
          20,
        ),
      ),
    ];
  }

  Widget _buildNextButton(BuildContext context) {
    final bool disabled = selectedForUpdate.isEmpty;
    return CMTextButton(
      backgroundColor: disabled ? Theme.of(context).colorScheme.surface : null,
      primary: disabled ? Theme.of(context).colorScheme.onSurface : null,
      noGradient: disabled,
      child: Text('WEITER'),
      onPressed: loading
          ? null
          : disabled
              ? null
              : () {
                  setState(() {
                    selectionFinished = true;
                  });
                },
    );
  }

  void _loadingListener(bool value) {
    setState(() {
      loading = value;
    });
  }

  Future<void> _successListener(bool value) async {
    if (value) {
      _reset(false);
      setState(() {
        loading = true;
      });
      await context.read<CCViewProvider>().reloadCurrentlyOpen();
      setState(() {
        loading = false;
      });
      context.read<CCViewProvider>().switchTo(
            ComponentContainerPage.currentState,
            toggleDrawer: false,
          );
    }
  }

  void _reset([bool shouldSetState = true]) {
    selectedForUpdate.clear();
    selectionFinished = false;
    if (shouldSetState) {
      setState(() {});
    }
  }
}
