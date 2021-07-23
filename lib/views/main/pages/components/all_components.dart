import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/provider/components/components_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
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
    final ComponentsViewProvider viewProvider =
        context.watch<ComponentsViewProvider>();

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpandedAppBar(
        appbarTitle: const Text('Alle Komponenten'),
        appbarChild: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              ExpandedTitle(
                title: 'Alle Komponenten',
              ),
              Text(
                'Aufklappen zum Einsehen der zusätzlichen Datenfelder.',
              ),
            ],
          ),
        ),
        offsetBeforeTitleShown: 50,
        onRefresh: provider.reload,
        loadingListener: (value) {
          setState(() {
            _loading = value;
          });
        },
        body: _loading
            ? LoadingList()
            : FutureBuilder(
                future: provider.components,
                builder:
                    (context, AsyncSnapshot<List<BaseComponent>> snapshot) {
                  if (snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.done) {
                    /// Future done but no data.
                    if (snapshot.data?.isEmpty ?? true) {
                      return Center(
                        child: const Text('Keine Komponenten gefunden.'),
                      );
                    }

                    /// Display the components
                    /// Apply the filter.
                    final List<BaseComponent> components = snapshot.data!
                        .where((element) => viewProvider.allowedCategories
                            .contains(element.category))
                        .toList();

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: components.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return _buildComponentWidget(
                          components[index],
                          isAdmin,
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
      ),
    );
  }

  Widget _buildComponentWidget(BaseComponent baseComponent, bool isAdmin) {
    return SimpleCard(
      margin: const EdgeInsets.all(SizeConfig.basePadding),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(
          SizeConfig.basePadding,
        ),
        childrenPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  baseComponent.name,
                ),
                Text(
                  baseComponent.category.name,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            if (isAdmin)
              IconButton(
                onPressed: () {
                  _showWarningDialog(baseComponent);
                },
                icon: Icon(
                  LineIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        children: [
          VehicleComponent(
            showBaseData: false,
            component: baseComponent,
          )
        ],
      ),
    );
  }

  void _showWarningDialog(BaseComponent component) {
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
              text: '${component.vehicleIds?.length ?? 0} ',
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
      confirmButton: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: SizeConfig.basePadding,
        ),
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
            setState(() {
              _loading = false;
            });
            if (!success) {
              _showErrorDialog();
            } else {
              /// Remove component from the list.
              await context.read<ComponentsProvider>().components.then(
                    (value) => value.remove(
                      component,
                    ),
                  );
            }
          },
        ),
      ),
      showCancelBtn: true,
      cancelButton: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: SizeConfig.basePadding,
        ),
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
      text: 'Bitte probiere es erneut oder wende dich an die IT.',
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
