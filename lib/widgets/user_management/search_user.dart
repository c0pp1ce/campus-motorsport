import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_user.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/user_management/user_card.dart';
import 'package:flutter/material.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({
    required this.users,
    this.onAccept,
    this.hint = '',
    Key? key,
  }) : super(key: key);

  final List<User> users;

  /// Shown when there are no users or search results.
  final String hint;

  /// Gets the uid of the selected user.
  /// Removes the user from results if the function result is true.
  final Future<bool> Function(CrudUser, User)? onAccept;

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  String? searchTerm;
  List<User>? results;

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return Text('Keine passenden Benutzer gefunden. ${widget.hint}');
    }

    return Column(
      children: <Widget>[
        CMTextField(
          hint: 'Name des Benutzers',
          label: 'Benutzersuche',
          onChanged: (value) {
            if (value != searchTerm) {
              setState(() {
                searchTerm = value;
                _search();
              });
            }
          },
        ),
        if ((searchTerm?.isNotEmpty ?? false) &&
            (results?.isEmpty ?? false)) ...[
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          SizedBox(
            width: SizeConfig.screenWidth,
            child: Text(
              'Keine Treffer. ${widget.hint}',
              textAlign: TextAlign.start,
            ),
          ),
        ],
        if ((searchTerm?.isNotEmpty ?? false) &&
            (results?.isNotEmpty ?? false)) ...[
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          SizedBox(
            width: SizeConfig.screenWidth,
            child: Text(
              'Suchergebnisse:',
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(
            height: SizeConfig.basePadding,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: results!.length,
            itemBuilder: (context, index) {
              final User user = results![index];
              return UserCard(
                key: ValueKey<String>(user.uid),
                user: user,
                confirmedWhenTrue: ConfirmedWhenTrue.isAdmin,
                confirmButton: widget.onAccept != null,
                declineButton: false,
                onConfirm: widget.onAccept == null
                    ? null
                    : (crudUser) async {
                        final bool success =
                            await widget.onAccept!(crudUser, user);
                        if (success) {
                          setState(() {
                            results?.removeAt(index);
                          });
                        }
                        return success;
                      },
                confirmErrorTitle: 'Fehler beim Ändern der Rolle.',
              );
            },
          ),
        ],
      ],
    );
  }

  void _search() {
    if (searchTerm?.isNotEmpty ?? false) {
      results = widget.users
          .where((element) =>
              element.name.toLowerCase().contains(searchTerm!.toLowerCase()))
          .toList();
    }
  }
}
