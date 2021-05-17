import 'package:campus_motorsport/widgets/general/layout/stacked_ui/context_drawer.dart';
import 'package:campus_motorsport/widgets/general/layout/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';


class Vehicles extends StatefulWidget {
  final String title;

  Vehicles(this.title);

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  @override
  Widget build(BuildContext context) {
    return MainView(
      title: Text(widget.title),
      child: Center(
        child: Text("Vehicles"),
      ),
    );
  }
}


class VehiclesContext extends StatefulWidget {
  VehiclesContext({Key? key}) : super(key: key);

  @override
  VehiclesContextState createState() => VehiclesContextState();
}

class VehiclesContextState extends State<VehiclesContext> {
  String text = "Vehicle context";

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