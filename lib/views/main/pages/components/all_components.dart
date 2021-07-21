import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
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
        appbarTitle: const Text('Alle Komponenten'),
        appbarChild: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExpandedTitle(
                title: 'Alle Komponenten',
              ),
              Text(
                'Aufklappen zum Einsehen der zusätzlichen Datenfelder.',
              ),
              if (isAdmin)
                Text(
                  'Swipe nach links zum Löschen von Komponenten.',
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
                    final List<BaseComponent> components = snapshot.data!;
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: components.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return SimpleCard(
                          margin: const EdgeInsets.all(SizeConfig.basePadding),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.all(
                              SizeConfig.basePadding,
                            ),
                            childrenPadding: EdgeInsets.zero,
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  components[index].name,
                                ),
                                Text(
                                  components[index].category.name,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                            children: [
                              VehicleComponent(
                                showBaseData: false,
                                component: components[index],
                              )
                            ],
                          ),
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
}
