import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';

/// A simple wrapper for a button which cancels the registration and navigates to
/// the login view afterwards.
class CancelRegistration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _controller = Provider.of<RegistrationController>(context, listen: false);
    return CMTextButton(
      primary: Theme.of(context).colorScheme.onSurface,
      gradient: LinearGradient(
        colors: <Color>[
          ColorServices.brighten(
              Theme.of(context)
                  .colorScheme
                  .surface
                  .withOpacity(0.7),
              25),
          Theme.of(context)
              .colorScheme
              .surface
              .withOpacity(0.9),
        ],
      ),
      onPressed: () {
        _controller.add(RequestCancelRequest());
        Navigator.of(context).pop();
      },
      child: const Text("ABBRECHEN"),
    );
  }
}
