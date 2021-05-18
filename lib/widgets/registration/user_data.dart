import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/services/validation_services.dart';
import 'package:campus_motorsport/widgets/registration/cancel_registration.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/basic_text_field.dart';
import 'package:campus_motorsport/widgets/general/style/simple_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The form widget where the user enters his data on registration.
class UserData extends StatefulWidget {
  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  RegistrationController? _controller;
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<RegistrationController>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text:
                    "Gib hier die nötigen Daten für die Registrierung ein.\n",
                style: Theme.of(context).textTheme.headline6,
                children: <TextSpan>[
                  TextSpan(
                    text: "Im Anschluss musst du deine Email Adresse bestätigen.\n"
                        "Im letzen Schritt muss die Registrierung durch einen Admin bestätigt werden.\n"
                        "Danach kann es losgehen!\n",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
            BasicTextField(
              hint: 'Gib deine E-Mail ein',
              label: 'E-Mail',
              textInputType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validate: (value) => ValidationServices().validateEmail(value),
              onSaved: (value) => _controller!.add(ChangeEmail(value)),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Vorname",
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.name,
              validate: (value) =>
                  ValidationServices().validateNotEmpty(value, "Vorname"),
              onSaved: (value) => _controller!.add(ChangeFirstname(value)),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Nachname",
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.name,
              validate: (value) =>
                  ValidationServices().validateNotEmpty(value, "Nachname"),
              onSaved: (value) => _controller!.add(ChangeLastname(value)),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Passwort",
              toggleObscure: true,
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.text,
              validate: (value) => ValidationServices().validatePassword(value),
              onSaved: (value) => _controller!.add(ChangePassword(value)),
            ),
            const SizedBox(
              height: 50,
            ),
            CMTextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  _controller!.add(RequestRegistration(
                    Provider.of<TokenController>(context, listen: false),
                  ));
                }
              },
              child: const Text("ACCOUNT ERSTELLEN"),
              loading: _controller!.loading,
            ),
            const SizedBox(
              height: 10,
            ),
            CancelRegistration(),
          ],
        ),
      ),
    );
  }
}
