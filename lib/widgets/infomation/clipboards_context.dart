import 'package:campus_motorsport/provider/information/information_view_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/infomation/clipboard_filter.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ClipBoardContext extends StatelessWidget {
  const ClipBoardContext({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContextDrawer(
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(SizeConfig.basePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipboardFiler(
                filterProvider: context.watch<InformationViewProvider>(),
              ),
              const SizedBox(
                height: SizeConfig.basePadding,
              ),
              _buildInfo(
                context,
                'Tippe auf ein Clipboard um die Detailansicht zu öffnen.',
                LineIcons.infoCircle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 65,
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
