import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
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
    final ComponentsProvider provider = context.watch<ComponentsProvider>();
    return ExpandedAppBar(
      appbarTitle: const Text('Alle Komponenten'),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Alle Komponenten',
        ),
      ),
      offsetBeforeTitleShown: 70,
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
              builder: (context, AsyncSnapshot<List<BaseComponent>> snapshot) {
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
                    itemExtent: 140,
                    itemBuilder: (context, index) {
                      return SimpleCard(
                        margin: const EdgeInsets.all(SizeConfig.basePadding),
                        child: Text(components[index].name),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
    );
  }
}
