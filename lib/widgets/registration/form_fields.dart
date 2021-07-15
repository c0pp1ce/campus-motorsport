import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/cards/simple_card.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:cool_alert/cool_alert.dart';

import 'package:flutter/material.dart';

/// The form widget where the user enters his data on registration.
class FormFields extends StatefulWidget {
  const FormFields({Key? key}) : super(key: key);

  @override
  _FormFieldsState createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // Data stored to be able to perform the registration.
  String? _email;
  String? _password;
  String? _firstname;
  String? _lastname;

  /// Used when performing the registration.
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_loading) {
          return false;
        }
        return true;
      },
      child: SimpleCard(
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
                      'Gib hier die nötigen Daten für die Registrierung ein.\n',
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
                onSaved: (value) {
                  _email = value;
                },
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
                onSaved: (value) {
                  _firstname = value;
                },
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
                onSaved: (value) {
                  _lastname = value;
                },
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
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(
                height: 50,
              ),
              CMTextButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();

                    /// Validators check for null values.
                    assert(
                      _email != null &&
                          _password != null &&
                          _firstname != null &&
                          _lastname != null,
                      'Some validators did not properly check for null values.',
                    );

                    /// Perform registration.
                    setState(() {
                      _loading = true;
                    });
                    final bool success = await CMAuth().register(
                      email: _email!,
                      password: _password!,
                      firstname: _firstname!,
                      lastname: _lastname!,
                    );
                    setState(() {
                      _loading = false;
                    });
                    if (!success) {
                      _showErrorDialog();
                    } else {
                      _showSuccessDialog();
                    }
                  }
                },
                child: const Text('ACCOUNT ERSTELLEN'),
                loading: _loading,
              ),
              const SizedBox(
                height: 10,
              ),
              CMTextButton(
                primary: Theme.of(context).colorScheme.onSurface,
                gradient: LinearGradient(
                  colors: <Color>[
                    ColorServices.brighten(
                        Theme.of(context).colorScheme.surface.withOpacity(0.7),
                        25),
                    Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  ],
                ),
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('ABBRECHEN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Registrierung fehlgeschlagen.',
      text:
          'Bitte überprüfe die eigegebenen Daten. Stell sicher, dass die E-Mail dir gehört und du noch keinen Account besitzt.\n'
          'Sollte der Fehler bestehen bleiben kontaktiere einen Administrator.',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'VERSTANDEN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }

  void _showSuccessDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.success,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Nächster Schritt: E-Mail Verifizierung.',
      text: 'Dir wurde ein Link zur Verifizierung deiner E-Mail geschickt.\n'
          'Im Anschluss daran muss der Account noch von einem Administrator bestätigt werden.',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'ZURÜCK ZUM LOGIN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }
}
