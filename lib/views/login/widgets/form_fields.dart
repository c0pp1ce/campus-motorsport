import 'package:campus_motorsport/controller/login_controller/login_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';
import 'package:campus_motorsport/services/validation_services.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/widgets/forms/basic_text_field.dart';
import 'package:provider/provider.dart';

/// The text fields of the login form.
class FormFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BasicTextField(
          hint: 'Gib deine E-Mail ein',
          label: 'E-Mail',
          textInputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
          validate: (value) => ValidationServices().validateEmail(value),
          onSaved: (value) {
            Provider.of<LoginController>(context, listen: false)
                .add(SaveEmail(value));
          },
        ),
        const SizedBox(
          height: 20,
        ),
        BasicTextField(
          hint: 'Gib dein Passwort ein',
          label: 'Passwort',
          textInputAction: TextInputAction.done,
          toggleObscure: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
          validate: (value) =>
              ValidationServices().validateNotEmpty(value, 'Passwort'),
          onSaved: (value) {
            Provider.of<LoginController>(context, listen: false)
                .add(SavePassword(value));
          },
        ),
      ],
    );
  }
}
