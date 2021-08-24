import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/provider/information/clipboard_provider.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/infomation/clipboard_view.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ClipboardTile extends StatelessWidget {
  const ClipboardTile({
    required this.clipboard,
    required this.isAdmin,
    required this.loadingListener,
    Key? key,
  }) : super(key: key);

  final Clipboard clipboard;
  final bool isAdmin;
  final void Function(bool) loadingListener;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(
          vertical: SizeConfig.basePadding, horizontal: SizeConfig.basePadding),
      child: ListTile(
        contentPadding: const EdgeInsets.all(SizeConfig.basePadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClipboardView(
                standAlone: true,
                clipboard: clipboard,
              ),
            ),
          );
        },
        title: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    clipboard.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    clipboard.type.name,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(
                    height: SizeConfig.basePadding,
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Column(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      final provider = context.read<ClipboardProvider>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClipboardView(
                            standAlone: true,
                            edit: true,
                            clipboard: clipboard,
                            clipboardProvider: provider,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      LineIcons.edit,
                    ),
                    splashRadius: SizeConfig.iconButtonSplashRadius,
                  ),
                  const SizedBox(
                    height: SizeConfig.basePadding,
                  ),
                  IconButton(
                    onPressed: () async {
                      final bool delete =
                          await _showWarningDialog(context) as bool? ?? false;
                      if (delete) {
                        loadingListener(true);
                        final bool success = await context
                            .read<ClipboardProvider>()
                            .delete(clipboard.id!);
                        loadingListener(false);
                        if (!success) {
                          _showErrorDialog(context);
                        }
                      }
                    },
                    icon: Icon(
                      LineIcons.trash,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    splashRadius: SizeConfig.iconButtonSplashRadius,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen fehlgeschlagen.',
      text: '',
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

  Future<dynamic> _showWarningDialog(BuildContext context) {
    return CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen bestätigen.',
      text: '',
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
            Navigator.of(context).pop(false);
          },
        ),
      ),
      confirmButton: Padding(
        padding: const EdgeInsets.only(left: SizeConfig.basePadding / 2),
        child: CMTextButton(
          child: const Text(
            'LÖSCHEN',
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      loopAnimation: false,
    );
  }
}
