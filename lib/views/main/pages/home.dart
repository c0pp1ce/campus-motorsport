import 'package:campus_motorsport/widgets/general/layout/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/main_view.dart';
import 'package:campus_motorsport/widgets/home/feed.dart';
import 'package:campus_motorsport/widgets/home/overview.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String currentPage = "Übersicht"; // TODO : Connect with provider.

  @override
  Widget build(BuildContext context) {
    return MainView(
      title: Text(currentPage),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: <Widget>[
            Overview(
              vehicleCount: 4,
              partCount: 33,
              userCount: 5,
            ),
            _spacer(1),
            Feed(),
          ],
        ),
      ),
    );
  }

  Widget _spacer(int factor) {
    return SizedBox(
      height: 10.0 * factor,
    );
  }
}

class HomeContext extends StatefulWidget {
  HomeContext({Key? key}) : super(key: key);

  @override
  HomeContextState createState() => HomeContextState();
}

class HomeContextState extends State<HomeContext> {
  String text = "Initial";

  @override
  Widget build(BuildContext context) {
    return ContextDrawer(
      child: Center(
          child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      )),
    );
  }

  void setText(String text) {
    setState(() {
      this.text = text;
    });
  }
}
