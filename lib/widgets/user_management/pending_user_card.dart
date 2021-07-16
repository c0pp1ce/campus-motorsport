import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class PendingUserCard extends StatefulWidget {
  const PendingUserCard({
    required this.user,
    Key? key,
  }) : super(key: key);

  final User user;

  @override
  _PendingUserCardState createState() => _PendingUserCardState();
}

class _PendingUserCardState extends State<PendingUserCard> {
  final CrudUser _crudUser = CrudUser();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: SimpleCard(
        margin: const EdgeInsets.all(SizeConfig.basePadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.headline6,
                    maxLines: 2,
                  ),
                  Text(
                    widget.user.email,
                    maxLines: 2,
                  ),
                  if (!widget.user.verified)
                    Text(
                      'Status der Verifizierung unbekannt.',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  if (widget.user.verified)
                    Text(
                      'Email verifiziert.',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _buildButtons(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : widget.user.accepted
            ? Icon(
                LineIcons.check,
                size: 48,
                color: Theme.of(context).colorScheme.secondary,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        final bool success = await _crudUser.updateField(
                          uid: widget.user.uid,
                          key: 'accepted',
                          data: true,
                        );
                        setState(() {
                          _loading = false;
                        });
                        if (!success) {
                          _showErrorDialog('Fehler beim Ändern der Rolle.');
                        } else {
                          setState(() {
                            widget.user.accepted = true;
                          });
                        }
                      },
                      icon: Icon(
                        LineIcons.check,
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        final bool success = await _crudUser.deleteUser(
                          uid: widget.user.uid,
                        );
                        setState(() {
                          _loading = false;
                        });
                        if (!success) {
                          _showErrorDialog('Fehler beim Löschen des Users.');
                        }
                      },
                      icon: Icon(
                        Icons.close,
                        size: 42,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
  }

  void _showErrorDialog(String title) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: title,
      text:
          'Oups. Bitte überprüfe deine Verbindung und lade die Seite neu (Pull to refresh).\n'
          'Sollte der Fehler bestehen bleiben wende dich an die IT.',
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
