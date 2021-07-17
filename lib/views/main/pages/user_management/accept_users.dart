import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/user_management/users_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_item.dart';
import 'package:campus_motorsport/widgets/user_management/pending_user_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The view where one can accept or decline pending users.
class AcceptUsers extends StatefulWidget {
  const AcceptUsers({
    Key? key,
  }) : super(key: key);

  @override
  _AcceptUsersState createState() => _AcceptUsersState();
}

class _AcceptUsersState extends State<AcceptUsers> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final UsersProvider provider = context.watch<UsersProvider>();

    return ExpandedAppBar(
      appbarTitle: Text('Ausstehende Bestätigungen'),
      appbarChild: Center(
        child: ExpandedTitle(
          title: 'Ausstehende Bestätigungen',
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
          ? _buildLoadingView(context)
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

                  /// Get all the users who have not been accepted and display
                  /// them.
                  final List<User> pendingUsers = snapshot.data!
                      .where((element) => !element.accepted)
                      .toList();
                  if (pendingUsers.isEmpty) {
                    return Center(
                      child: Text('Keine zu bestätigende Benutzer.'),
                    );
                  }

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pendingUsers.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PendingUserCard(
                        user: pendingUsers[index],
                        key: ValueKey<String>(pendingUsers[index].uid),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemExtent: 140,
      itemBuilder: (context, index) {
        return const LoadingItem(
          child: SimpleCard(
            margin: EdgeInsets.all(SizeConfig.basePadding),
            child: SizedBox(),
          ),
        );
      },
    );
  }
}
