import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/component_containers/cc_provider.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/provider/components/components_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';
import 'package:campus_motorsport/services/color_services.dart';
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

class AllComponents extends StatefulWidget {
  const AllComponents({Key? key}) : super(key: key);

  @override
  _AllComponentsState createState() => _AllComponentsState();
}

class _AllComponentsState extends State<AllComponents> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;
    final ComponentsProvider provider = context.watch<ComponentsProvider>();

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpandedAppBar(
        appbarTitle: Text(
          'Alle Komponenten',
          style: Theme.of(context).textTheme.headline6,
        ),
        appbarChild: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding,
          ),
          child: const Center(
            child: ExpandedTitle(
              title: 'Alle Komponenten',
            ),
          ),
        ),
        offsetBeforeTitleShown: 60,
        onRefresh: provider.reload,
        loadingListener: (value) {
          setState(() {
            _loading = value;
          });
        },
        body: _buildBody(context, isAdmin, provider),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, bool isAdmin, ComponentsProvider provider) {
    return _loading ? LoadingList() : _buildList(context, provider, isAdmin);
  }

  Widget _buildList(
      BuildContext context, ComponentsProvider provider, bool isAdmin) {
    if (provider.components.isEmpty) {
      /// Future done but no data.
      return Center(
        child: const Text('Keine Komponenten gefunden.'),
      );
    }

    /// Display the components
    /// Apply the filter.
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();
    final List<BaseComponent> components = provider.components
        .where((element) =>
            viewProvider.allowedCategories.contains(element.category))
        .toList();

    return ListView.builder(
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
              ExpansionComponent(
                key: ValueKey(
                  components[index].id ?? components[index].name,
                ),
                component: components[index],
                isAdmin: isAdmin,
                showDeleteDialog: _showDeleteDialog,
              ),
            ],
          );
        } else {
          return ExpansionComponent(
            key: ValueKey(
              components[index].id ?? components[index].name,
            ),
            component: components[index],
            isAdmin: isAdmin,
            showDeleteDialog: _showDeleteDialog,
          );
        }
      },
    );
  }

  void _showDeleteDialog(BaseComponent component) {
    CoolAlert.show(
      barrierDismissible: false,
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen bestätigen.',
      text: '',
      widget: RichText(
        text: TextSpan(
          text: 'Die Komponente wird von ',
          children: <TextSpan>[
            TextSpan(
              text: '${component.usedBy?.length ?? 0} ',
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            TextSpan(
              text: 'Fahrzeugen/Lagern verwendet.\n\n'
                  'Durch das Löschen wird die Komponente von diesen Fahrzeugen entfernt.',
            ),
          ],
        ),
      ),
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
            final bool success = await CrudComponent().deleteComponent(
              component,
            );
            if (!success) {
              _showErrorDialog();
            } else {
              /// Remove component from the list.
              await context.read<ComponentsProvider>().reload();
              await context.read<StocksProvider>().reload(false);
              await context.read<VehiclesProvider>().reload(false);
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
