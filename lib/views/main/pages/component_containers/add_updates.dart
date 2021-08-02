import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/services/color_services.dart';
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
  late final List<bool> selectedArray;
  bool selectionFinished = false;
  bool loading = false;

  @override
  void initState() {
    selectedArray = List.filled(
      context.read<CCViewProvider>().currentlyOpen!.components.length,
      false,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();
    assert(viewProvider.currentlyOpen != null);
    final ComponentContainer currentContainer = viewProvider.currentlyOpen!;
    final List<BaseComponent> allComponents =
        context.watch<ComponentsProvider>().components;
    final List<BaseComponent> containerComponents = allComponents
        .where((element) => currentContainer.components.contains(element.id))
        .toList();

    return ExpandedAppBar(
      offsetBeforeTitleShown: 50,
      appbarTitle: Text(
        !selectionFinished ? 'Komponenten auswählen' : 'Wartungen eintragen',
      ),
      appbarChild: Center(
        child: ExpandedTitle(
          title: !selectionFinished
              ? 'Komponenten auswählen'
              : 'Wartungen eintragen',
        ),
      ),
      actions: _buildActions(context),
      body: loading
          ? LoadingList()
          : !selectionFinished
              ? ComponentSelectionPreUpdate(
                  components: containerComponents,
                  selectedValues: selectedArray,
                  doneButton: _buildNextButton(context),
                  onSelect: (index) {
                    setState(() {
                      if (selectedForUpdate
                          .contains(containerComponents[index])) {
                        selectedForUpdate.remove(containerComponents[index]);
                        selectedArray[index] = false;
                      } else {
                        selectedArray[index] = true;
                        selectedForUpdate.add(containerComponents[index]);
                      }
                    });
                  },
                )
              : UpdateComponents(
                  // key: ValueKey('updateComponents${currentContainer.id}'),
                  currentContainer: currentContainer,
                  selectedComponents: selectedForUpdate,
                  loadingListener: _loadingListener,
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

  void _reset() {
    setState(() {
      selectedArray.fillRange(0, selectedArray.length, false);
      selectedForUpdate.clear();
      selectionFinished = false;
    });
  }
}