import 'package:campus_motorsport/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';

class RegistrationView extends StatefulWidget {
  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account erstellen'),
        automaticallyImplyLeading: false,
        leading: CMTextButton(
          primary: Theme.of(context).colorScheme.onSurface,
          noGradient: true,
          child: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, loginRoute);
          },
        ),
      ),
      body: Container(),
    );
  }
}
