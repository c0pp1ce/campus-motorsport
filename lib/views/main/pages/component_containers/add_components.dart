import 'dart:math';

import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/component_selection_tile.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

/// View where a user can add new components to a component container.
class AddComponents extends StatefulWidget {
  const AddComponents({
    Key? key,
  }) : super(key: key);

  @override
  _AddComponentsState createState() => _AddComponentsState();
}

class _AddComponentsState extends State<AddComponents> {
  List<BaseComponent> selected = [];
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    /// Some error occurred.
    if (viewProvider.currentlyOpen == null) {
      const ExpandedAppBar(
        appbarTitle: Text('Fehler beim Laden.'),
        offsetBeforeTitleShown: 0,
        appbarChild: SizedBox(),
      );
    }

    final ComponentContainer componentContainer = viewProvider.currentlyOpen!;
    final List<BaseComponent> components =
        context.watch<ComponentsProvider>().components;
    late final List<BaseComponent> notYetAdded;
    if (componentContainer.components.length == components.length) {
      notYetAdded = [];
    } else {
      notYetAdded = components.where((component) {
        return !componentContainer.components.contains(component.id) &&
            viewProvider.allowedCategories.contains(component.category);
      }).toList();
    }

    return ExpandedAppBar(
      onRefresh: context.read<ComponentsProvider>().reload,
      loadingListener: (value) {
        setState(() {
          loading = value;
        });
      },
      appbarTitle: Text(
        'Komponenten hinzufügen',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExpandedTitle(
            title: 'Komponenten hinzufügen',
          ),
          Text(
            componentContainer.name,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: ColorServices.darken(
                      Theme.of(context).colorScheme.onSurface, 40),
                ),
          ),
        ],
      ),
      actions: _buildActions(context, componentContainer),
      offsetBeforeTitleShown: 50,
      body: loading
          ? LoadingList()
          : ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              // Fix so that empty list case can be handled inside the builder as well.
              itemCount: max<int>(notYetAdded.length, 1),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if (notYetAdded.isEmpty) {
                  return Center(
                    child: Text('Keine Komponenten hinzufügbar.'),
                  );
                }

                final bool compSelected = selected.contains(notYetAdded[index]);
                late final bool categoryChanged;
                if (index == 0) {
                  categoryChanged = true;
                } else {
                  if (notYetAdded[index - 1].category !=
                      notYetAdded[index].category) {
                    categoryChanged = true;
                  } else {
                    categoryChanged = false;
                  }
                }

                if (categoryChanged) {
                  return Column(
                    children: <Widget>[
                      if (index != 0)
                        const SizedBox(
                          height: SizeConfig.basePadding,
                        ),
                      ListSubHeader(
                        header: notYetAdded[index].category.name,
                      ),
                      const SizedBox(
                        height: SizeConfig.basePadding,
                      ),
                      ComponentSelectionTile(
                        component: notYetAdded[index],
                        selected: compSelected,
                        onSelect: () {
                          setState(() {
                            if (compSelected) {
                              selected.remove(notYetAdded[index]);
                            } else {
                              selected.add(notYetAdded[index]);
                            }
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return ComponentSelectionTile(
                    component: notYetAdded[index],
                    selected: compSelected,
                    onSelect: () {
                      setState(() {
                        if (compSelected) {
                          selected.remove(notYetAdded[index]);
                        } else {
                          selected.add(notYetAdded[index]);
                        }
                      });
                    },
                  );
                }
              },
            ),
    );
  }

  /// This page is only shown to admins therefore no need to check admin rights
  /// again.
  List<Widget> _buildActions(
    BuildContext context,
    ComponentContainer componentContainer,
  ) {
    return loading
        ? [
            Container(
              height: 50,
              width: 55,
              padding: const EdgeInsets.all(SizeConfig.basePadding),
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ]
        : [
            IconButton(
              onPressed: _reset,
              icon: Icon(
                LineIcons.trash,
                color: ColorServices.darken(
                  Theme.of(context).colorScheme.secondary,
                  20,
                ),
              ),
              splashRadius: SizeConfig.iconButtonSplashRadius,
            ),
            const SizedBox(
              width: SizeConfig.basePadding,
            ),
            IconButton(
              onPressed: () {
                _save(context, componentContainer);
              },
              icon: Icon(
                LineIcons.save,
                size: 30,
              ),
              splashRadius: SizeConfig.iconButtonSplashRadius,
            ),
          ];
  }

  void _reset() {
    setState(() {
      selected = [];
    });
  }

  Future<void> _save(BuildContext context, ComponentContainer container) async {
    bool success = true;
    if (selected.isEmpty) {
      success = false;
    }
    if (container.id?.isEmpty ?? true) {
      success = false;
    }

    if (!success) {
      return;
    }

    setState(() {
      loading = true;
    });

    final List<String> selection = [];
    for (final component in selected) {
      assert(component.id != null);
      selection.add(component.id!);
    }
    success = await CrudCompContainer().addComponents(
      docId: container.id!,
      data: selection,
    );

    if (success) {
      await context.read<ComponentsProvider>().reload();
      await context.read<CCViewProvider>().reloadCurrentlyOpen();
    } else {
      _showErrorDialog();
    }

    setState(() {
      selected = [];
      loading = false;
    });
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: 'Bitte überprüfe die Verbindung und versuche es erneut.\n'
          'Bleibt der Fehler bestehen wende dich an die IT.',
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
