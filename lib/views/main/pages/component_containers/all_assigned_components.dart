import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/expansion_component.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllAssignedComponents extends StatefulWidget {
  const AllAssignedComponents({Key? key}) : super(key: key);

  @override
  _AllAssignedComponentsState createState() => _AllAssignedComponentsState();
}

class _AllAssignedComponentsState extends State<AllAssignedComponents> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      onRefresh: context.read<CCViewProvider>().reloadCurrentlyOpen,
      loadingListener: (value) {
        setState(() {
          _loading = value;
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
            context.watch<CCViewProvider>().currentlyOpen!.name,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    SizeConfig.darkenTextColorBy,
                  ),
                ),
          ),
        ],
      ),
      offsetBeforeTitleShown: 50,
      body: _loading ? LoadingList() : _buildBody(),
    );
  }

  Widget _buildBody() {
    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;
    final ComponentsProvider provider = context.watch<ComponentsProvider>();
    final CCViewProvider ccViewProvider = context.watch<CCViewProvider>();
    final List<String> componentIds = ccViewProvider.currentlyOpen!.components;
    final List<BaseComponent> components = provider.components
        .where((element) =>
            componentIds.contains(element.id) &&
            ccViewProvider.allowedCategories.contains(element.category))
        .toList();

    if (components.isEmpty) {
      return Center(
        child: const Text('Keine Komponenten gefunden.'),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: components.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          late final bool categoryChanged;
          if (index == 0) {
            categoryChanged = true;
          } else {
            if (components[index - 1].category != components[index].category) {
              categoryChanged = true;
            } else {
              categoryChanged = false;
            }
          }

          final Widget child = ExpansionComponent(
            isAdmin: isAdmin,
            component: components[index],
            showDeleteDialog: (component) {
              _showDeleteDialog(
                component,
                context.read<CCViewProvider>().currentlyOpen!.id!,
              );
            },
          );

          if (categoryChanged) {
            return Column(
              children: <Widget>[
                if (index != 0)
                  const SizedBox(
                    height: SizeConfig.basePadding,
                  ),
                ListSubHeader(
                  header: components[index].category.name,
                ),
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
                child,
              ],
            );
          } else {
            return child;
          }
        },
      ),
    );
  }

  void _showDeleteDialog(BaseComponent component, String docId) {
    CoolAlert.show(
      barrierDismissible: false,
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen bestätigen.',
      text: 'Willst du die Komponente wirklich löschen?\n'
          'Alle damit verbundenen Wartungen werden ebenfalls gelöscht.',
      confirmButton: Padding(
        padding: const EdgeInsets.only(left: SizeConfig.basePadding / 2),
        child: CMTextButton(
          child: const Text(
            'VERSTANDEN',
          ),
          onPressed: () async {
            setState(() {
              _loading = true;
            });

            /// Leave dialog in order to avoid stacked dialogs.
            Navigator.of(context).pop();

            /// Try to delete the component.
            final bool success = await CrudCompContainer().deleteComponent(
              docId: docId,
              componentId: component.id!,
              fromUpdates: true,
            );
            if (!success) {
              _showErrorDialog();
            } else {
              /// Remove component from the list.
              await context.read<CCViewProvider>().reloadCurrentlyOpen();
            }
            setState(() {
              _loading = false;
            });
          },
        ),
      ),
      showCancelBtn: true,
      cancelButton: Padding(
        padding: const EdgeInsets.only(right: SizeConfig.basePadding / 2),
        child: CMTextButton(
          primary: Theme.of(context).colorScheme.onSurface,
          child: const Text(
            'ABBRECHEN',
          ),
          gradient: LinearGradient(
            colors: <Color>[
              ColorServices.brighten(
                Theme.of(context).colorScheme.surface.withOpacity(0.7),
                25,
              ),
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      loopAnimation: false,
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen fehlgeschlagen.',
      text: 'Lade die Seite neu und probiere es erneut.',
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
