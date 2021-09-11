import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/user_management/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceList extends StatelessWidget {
  const AttendanceList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<CurrentUser>().user;
    if (currentUser == null) {
      return const SizedBox();
    }
    return ExpandedAppBar(
      showOnSiteIndicator: true,
      offsetBeforeTitleShown: 30,
      appbarTitle: const Text('Anwesenheitsliste'),
      appbarChild: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const ExpandedTitle(
            title: 'Anwesenheitsliste',
            margin: EdgeInsets.zero,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Derzeit vor Ort',
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      fontSize: 16,
                    ),
              ),
              Switch(
                value: currentUser.onSite,
                onChanged: (value) {
                  context.read<CurrentUser>().setOnSiteState(value);
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('onSite', isEqualTo: true)
            .snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (!snapshot.hasData) {
            return LoadingList();
          }
          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot user) {
              if (user.data() == null) {
                return const SizedBox();
              }
              return UserCard(
                user: User.fromJson(user.data()! as Map<String, dynamic>),
                confirmButton: false,
                declineButton: false,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
