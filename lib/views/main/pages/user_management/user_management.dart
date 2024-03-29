import 'package:campus_motorsport/provider/user_management/user_management_provider.dart';
import 'package:campus_motorsport/views/main/pages/user_management/accept_users.dart';
import 'package:campus_motorsport/views/main/pages/user_management/admins.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserManagementProvider pageProvider =
        context.watch<UserManagementProvider>();

    switch (pageProvider.currentPage) {
      case UMPage.acceptUsers:
        return const AcceptUsers();
      case UMPage.admins:
        return const Admins();
    }
  }
}

class UserManagementSecondary extends StatelessWidget {
  const UserManagementSecondary({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserManagementProvider pageProvider =
        context.watch<UserManagementProvider>();

    return Material(
      color: Colors.transparent,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: UMPage.values.map((page) {
          return ListTile(
            title: Text(
              page.pageName,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: pageProvider.currentPage == page
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
            onTap: () {
              pageProvider.switchTo(page);
            },
          );
        }).toList(),
      ),
    );
  }
}
