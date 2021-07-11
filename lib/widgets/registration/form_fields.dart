import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';

import 'package:flutter/material.dart';

/// The form widget where the user enters his data on registration.
class FormFields extends StatefulWidget {
  const FormFields({Key? key}) : super(key: key);

  @override
  _FormFieldsState createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  final GlobalKey<FormState> _formKey = GlobalKey();

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
                text: 'Gib hier die nötigen Daten für die Registrierung ein.\n',
                style: Theme.of(context).textTheme.headline6,
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'Im Anschluss musst du deine Email Adresse bestätigen.\n'
                        'Im letzen Schritt muss die Registrierung durch einen Admin bestätigt werden.\n'
                        'Danach kann es losgehen!\n',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
            ),
            CMTextField(
              hint: 'Gib deine E-Mail ein',
              label: 'E-Mail',
              textInputType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validate: (value) => Validators().validateEmail(value),
              onSaved: (value) {}, // TODO : save email
            ),
            const SizedBox(
              height: 20,
            ),
            CMTextField(
              label: 'Vorname',
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.name,
              validate: (value) =>
                  Validators().validateNotEmpty(value, 'Vorname'),
              onSaved: (value) {}, // TODO : Save firstname
            ),
            const SizedBox(
              height: 20,
            ),
            CMTextField(
              label: 'Nachname',
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.name,
              validate: (value) =>
                  Validators().validateNotEmpty(value, 'Nachname'),
              onSaved: (value) {}, // TODO : save lastname
            ),
            const SizedBox(
              height: 20,
            ),
            CMTextField(
              label: 'Passwort',
              toggleObscure: true,
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.text,
              validate: (value) => Validators().validatePassword(value),
              onSaved: (value) {}, // TODO : Save password
            ),
            const SizedBox(
              height: 50,
            ),
            CMTextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  // TODO : perform registration
                }
              },
              child: const Text('ACCOUNT ERSTELLEN'),
              loading: false, // TODO : Loading state
            ),
            const SizedBox(
              height: 10,
            ),
            CMTextButton(
              primary: Theme.of(context).colorScheme.onSurface,
              loading: false, // TODO : Loading state
              gradient: LinearGradient(
                colors: <Color>[
                  ColorServices.brighten(
                      Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      25),
                  Theme.of(context).colorScheme.surface.withOpacity(0.9),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ABBRECHEN'),
            ),
          ],
        ),
      ),
    );
  }
}
