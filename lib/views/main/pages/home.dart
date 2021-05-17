import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/layout/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String title;

  Home(this.title);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MainView(
      title: Text(widget.title),
      child: Center(
        child: CMTextButton(
          width: 100,
          height: 35,
          child: Text("Surprise"),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Test"),
                actions: [
                  CMTextButton(
                    width: 100,
                    height: 40,
                    child: Text("Leave"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CMTextButton(
                    width: 100,
                    height: 40,
                    child: Text("Change"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
