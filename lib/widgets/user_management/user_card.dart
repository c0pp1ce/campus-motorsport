import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

enum ConfirmedWhenTrue { accepted, isAdmin, never }

/// If either button is wanted, the corresponding function needs to be given as well.
class UserCard extends StatefulWidget {
  const UserCard({
    required this.user,
    required this.confirmButton,
    required this.declineButton,
    this.onConfirm,
    this.onDecline,
    this.confirmedWhenTrue,
    this.confirmErrorTitle,
    this.declineErrorTitle,
    this.showEmailState = true,
    this.showRoles = false,
    Key? key,
  })  : assert(!confirmButton || confirmButton && onConfirm != null),
        assert(!declineButton || declineButton && onDecline != null),
        super(key: key);

  final User user;
  final ConfirmedWhenTrue? confirmedWhenTrue;

  /// Shows if the email is verified.
  final bool showEmailState;

  /// If this is set to true no buttons will be shown.
  final bool showRoles;

  final bool confirmButton;
  final Future<bool> Function(CrudUser)? onConfirm;
  final String? confirmErrorTitle;

  final bool declineButton;
  final Future<bool> Function(CrudUser)? onDecline;
  final String? declineErrorTitle;

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final CrudUser _crudUser = CrudUser();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.showRoles ? 160 : 140,
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
                  if (!widget.user.verified && widget.showEmailState)
                    Text(
                      'Status der Verifizierung unbekannt.',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  if (widget.user.verified && widget.showEmailState)
                    Text(
                      'Email verifiziert.',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  if (widget.showRoles)
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _showRoles(),
                      ),
                    ),
                ],
              ),
            ),
            if (!widget.showRoles)
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

  Widget _showRoles() {
    final TextStyle? style = Theme.of(context).textTheme.bodyText2?.copyWith(
          fontSize: 12,
        );

    return Wrap(
      spacing: SizeConfig.basePadding,
      children: [
        if (widget.user.verified)
          Chip(
            backgroundColor:
                ColorServices.darken(Theme.of(context).colorScheme.primary, 70),
            label: Text(
              'Verifiziert',
              style: style,
            ),
          ),
        if (widget.user.accepted)
          Chip(
            backgroundColor:
                ColorServices.darken(Theme.of(context).colorScheme.primary, 65),
            label: Text(
              'Bestätigt',
              style: style,
            ),
          ),
        if (widget.user.isAdmin)
          Chip(
            backgroundColor:
                ColorServices.darken(Theme.of(context).colorScheme.primary, 60),
            label: Text(
              'Admin',
              style: style,
            ),
          ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : _confirmed()
            ? Icon(
                LineIcons.check,
                size: 48,
                color: Theme.of(context).colorScheme.secondary,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (widget.confirmButton)
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                          });
                          final bool success =
                              await widget.onConfirm!(_crudUser);
                          setState(() {
                            _loading = false;
                          });
                          if (!success) {
                            _showErrorDialog(
                              widget.confirmErrorTitle ??
                                  'Fehler beim Bestätigen.',
                            );
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
                  if (widget.declineButton)
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            _loading = true;
                          });
                          final bool success =
                              await widget.onDecline!(_crudUser);
                          setState(() {
                            _loading = false;
                          });
                          if (!success) {
                            _showErrorDialog(widget.declineErrorTitle ??
                                'Fehler beim Ablehnen.');
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

  bool _confirmed() {
    switch (widget.confirmedWhenTrue) {
      case ConfirmedWhenTrue.accepted:
        return widget.user.accepted;
      case ConfirmedWhenTrue.isAdmin:
        return widget.user.isAdmin;
      case ConfirmedWhenTrue.never:
        return false;
      default:
        return false;
    }
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
