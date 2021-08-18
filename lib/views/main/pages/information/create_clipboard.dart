import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/infomation/clipboard_view.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class CreateClipboard extends StatefulWidget {
  const CreateClipboard({Key? key}) : super(key: key);

  @override
  _CreateClipboardState createState() => _CreateClipboardState();
}

class _CreateClipboardState extends State<CreateClipboard> {
  bool _loading = false;
  final GlobalKey<ClipboardViewState> cvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      appbarTitle: Text(
        'Clipboard erstellen',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SizeConfig.basePadding,
        ),
        child: const Center(
          child: ExpandedTitle(
            title: 'Clipboard erstellen',
          ),
        ),
      ),
      offsetBeforeTitleShown: 50,
      loadingListener: (value) {
        setState(() {
          _loading = value;
        });
      },
      actions: [
        if (_loading)
          Container(
            height: 50,
            width: 55,
            padding: const EdgeInsets.all(SizeConfig.basePadding),
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        if (!_loading)
          IconButton(
            onPressed: () {
              cvKey.currentState?.reset();
            },
            icon: Icon(
              LineIcons.trash,
              color: ColorServices.darken(
                Theme.of(context).colorScheme.secondary,
                20,
              ),
            ),
            splashRadius: SizeConfig.iconButtonSplashRadius,
          ),
        if (!_loading)
          IconButton(
            onPressed: () async {
              await cvKey.currentState?.save();
            },
            icon: Icon(
              LineIcons.save,
              size: 30,
            ),
            splashRadius: SizeConfig.iconButtonSplashRadius,
          ),
      ],
      body: _loading ? LoadingList() : _buildBody(),
    );
  }

  Widget _buildBody() {
    return ClipboardView(
      key: cvKey,
      create: true,
      standAlone: false,
      loadingListener: (value) {
        setState(() {
          _loading = value;
        });
      },
    );
  }
}
