import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/user_management/users_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/user_management/search_user.dart';
import 'package:campus_motorsport/widgets/user_management/user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// See current admins, give admin rights to other users.
class Admins extends StatefulWidget {
  const Admins({
    Key? key,
  }) : super(key: key);

  @override
  _AdminsState createState() => _AdminsState();
}

class _AdminsState extends State<Admins> {
  bool _loading = false;
  late List<User> admins;
  late List<User> noAdmins;

  @override
  Widget build(BuildContext context) {
    final UsersProvider provider = context.watch<UsersProvider>();

    return ExpandedAppBar(
      showOnSiteIndicator: true,
      appbarTitle: Text(
        'Administratoren',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Administratoren-Verwaltung',
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
          ? const LoadingList()
          : FutureBuilder(
              future: provider.users,
              builder: (context, AsyncSnapshot<List<User>> snapshot) {
                /// hasData/hasError are not reset if the future changes. But since
                /// the _loading flag is used above there is no need to adjust
                /// the FutureBuilder.
                if (snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.done) {
                  /// Future done but no data.
                  if (snapshot.data?.isEmpty ?? true) {
                    return Center(
                      child: Text('Keine Benutzer gefunden.'),
                    );
                  }

                  /// Get all the users who are admins.
                  /// Based on DB rules admins need to be accepted users and need to have
                  /// verified their email.
                  admins = snapshot.data!
                      .where((element) =>
                          element.verified &&
                          element.accepted &&
                          element.isAdmin)
                      .toList();

                  /// Get all the users who are no admins. Used to search for users
                  /// in order to give them admin rights. Only verified & accepted
                  /// users will be able to use their admin rights.
                  noAdmins = snapshot.data!
                      .where((element) =>
                          !element.isAdmin &&
                          element.verified &&
                          element.accepted)
                      .toList();

                  return Container(
                    width: SizeConfig.screenWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SizeConfig.basePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildSectionTitle('Administrator ernennen'),
                        const SizedBox(
                          height: SizeConfig.basePadding,
                        ),
                        SearchUser(
                          users: noAdmins,
                          hint:
                              '\nBenutzer müssen bestätigt und verifiziert sein um Admins werden zu können.',
                          onAccept: (crudUser, user) async {
                            final bool success = await crudUser.updateField(
                              uid: user.uid,
                              key: 'isAdmin',
                              data: true,
                            );
                            if (success) {
                              setState(() {
                                user.isAdmin = true;
                              });
                            }
                            return success;
                          },
                        ),
                        const SizedBox(
                          height: SizeConfig.basePadding * 2,
                        ),
                        _buildSectionTitle('Aktuelle Administratoren'),
                        const SizedBox(
                          height: SizeConfig.basePadding,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: admins.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return UserCard(
                              user: admins[index],
                              key: ValueKey<String>(admins[index].uid),
                              confirmedWhenTrue: ConfirmedWhenTrue.never,
                              confirmButton: false,
                              declineButton: false,
                              showEmailState: false,
                              showRoles: true,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
