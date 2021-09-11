import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/provider/information/clipboard_provider.dart';
import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/list_sub_header.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/infomation/clipboard_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Clipboards extends StatefulWidget {
  const Clipboards({Key? key}) : super(key: key);

  @override
  _ClipboardsState createState() => _ClipboardsState();
}

class _ClipboardsState extends State<Clipboards> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<ClipboardProvider>();
    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;
    late final Widget body;

    if (dataProvider.clipboards.isEmpty) {
      body = Center(child: Text('Keine Daten gefunden.'));
    } else {
      body = _buildBody(context, dataProvider, isAdmin);
    }

    return ExpandedAppBar(
      showOnSiteIndicator: true,
      appbarTitle: Text(
        'Clipboards',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SizeConfig.basePadding,
        ),
        child: const Center(
          child: ExpandedTitle(
            title: 'Clipboards',
          ),
        ),
      ),
      offsetBeforeTitleShown: 50,
      onRefresh: dataProvider.getAll,
      loadingListener: (value) {
        setState(() {
          _loading = value;
        });
      },
      body: _loading ? LoadingList() : body,
    );
  }

  Widget _buildBody(
    BuildContext context,
    ClipboardProvider dataProvider,
    bool isAdmin,
  ) {
    final List<Clipboard> boards = dataProvider.clipboards
        .where((element) => context
            .watch<InformationViewProvider>()
            .allowedCategories
            .contains(element.type))
        .toList();
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: boards.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        late final bool dateChanged;
        if (index == 0) {
          dateChanged = true;
        } else {
          if (boards[index - 1].eventDate != boards[index].eventDate) {
            dateChanged = true;
          } else {
            dateChanged = false;
          }
        }

        final Widget child = ClipboardTile(
          clipboard: boards[index],
          isAdmin: isAdmin,
          loadingListener: (value) {
            setState(() {
              _loading = value;
            });
          },
        );

        if (dateChanged) {
          return Column(
            children: <Widget>[
              if (index != 0)
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
              ListSubHeader(
                header: DateFormat.yMMMMd().format(
                  boards[index].eventDate.toLocal(),
                ),
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
    );
  }
}
