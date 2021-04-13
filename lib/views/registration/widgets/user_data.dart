import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/services/validation_services.dart';
import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/forms/basic_text_field.dart';
import 'package:campus_motorsport/widgets/layout/simple_card.dart';
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
    _controller!.addListener(() {
      this._listener();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.removeListener(() {
      this._listener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: RichText(
                text: TextSpan(
                  text: "Registrierung abschließen\n\n",
                  style: Theme.of(context).textTheme.headline6,
                  children: <TextSpan>[
                    TextSpan(
                      text: "Gleich hast du es geschafft!\n",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            BasicTextField(
              enabled: false,
              label: "Einladungscode",
              initialValue: _controller!.invitationCode,
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              enabled: false,
              label: "E-Mail",
              initialValue: _controller!.email,
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Vorname",
              textInputAction: TextInputAction.next,
              validate: (value) => ValidationServices().validateNotEmpty(value, "Vorname"),
              onSaved: (value) => _controller!.add(ChangeFirstname(value)),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Nachname",
              textInputAction: TextInputAction.next,
              validate: (value) => ValidationServices().validateNotEmpty(value, "Nachname"),
              onSaved: (value) => _controller!.add(ChangeLastname(value)),
            ),
            const SizedBox(
              height: 20,
            ),
            BasicTextField(
              label: "Passwort",
              toggleObscure: true,
              textInputAction: TextInputAction.done,
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
          ],
        ),
      ),
    );
  }

  /// The reactions to controller changes.
  void _listener() {
    if (!mounted) return;

    /// Redraw UI on changes. Cannot use listen: true in initState as it might cause errors.
    setState(() {
      /// Switch to next form if code has been validated by the backend.
      if (_controller!.success && !_controller!.cancelRequest) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          Navigator.of(context)
              .pushReplacementNamed(homeRoute); // TODO : Onboarding wanted?
        });
      }
    });
  }
}
