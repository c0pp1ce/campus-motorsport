import 'package:flutter/material.dart';

import 'package:campus_motorsport/widgets/forms/basic_text_field.dart';

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
          validate: (value) {
            if (value?.isEmpty ?? true) return 'Bitte gib deine E-Mail ein.';
            return null;
          },
          // TODO : Implement onSaved
          onSaved: (_) {},
        ),
        SizedBox(
          height: 20,
        ),
        BasicTextField(
          hint: 'Gib dein Passwort ein',
          label: 'Passwort',
          textInputAction: TextInputAction.done,
          toggleObscure: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
          validate: (value) {
            if (value?.isEmpty ?? true) return 'Bitte gib dein Passwort ein.';
            return null;
          },
          // TODO : Implement onSaved
          onSaved: (_) {},
        ),
      ],
    );
  }
}
