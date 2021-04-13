import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/services/validation_services.dart';
import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/forms/basic_text_field.dart';
import 'package:campus_motorsport/widgets/forms/code_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// The first registration form where the code & email are entered.
class CodeCheck extends StatefulWidget {
  /// This function will be called when the code is correct and the next form
  /// shall be shown.
  final void Function() switchForm;

  CodeCheck({required this.switchForm, Key? key}) : super(key: key);

  @override
  _CodeCheckState createState() => _CodeCheckState();
}

class _CodeCheckState extends State<CodeCheck> {
  RegistrationController? _controller;

  /// The form key for code & email input.
  GlobalKey<FormState> _formKey = GlobalKey();

  /// Indicates if input code validation failed.
  bool _codeError = false;

  @override
  void initState() {
    super.initState();

    _controller = Provider.of<RegistrationController>(context, listen: false);
    _controller!.addListener(() {
      /// Redraw UI on changes. Cannot use listen: true in initState as it might cause errors.
      setState(() {
        /// Switch to next form if code has been validated by the backend.
        if (_controller!.validCode) {
          widget.switchForm();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: RichText(
                  text: TextSpan(
                    text: "Deine Einladung\n\n",
                    style: Theme.of(context).textTheme.headline6,
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "Gib hier den Code und die Email-Adresse ein, an die der Code gesendet wurde.\n"
                            "Diese Email-Adresse wird auch deine Login-Email sein.\n",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              ),
              CodeInput(
                enabled: !_controller!.validCode,
                error: _codeError,
                textInputType: TextInputType.text,
                onSaved: (value) =>
                    _controller!.add(ChangeInvitationCode(value)),
                validate: (value) {
                  String? error =
                      ValidationServices().validateInvitationCode(value);
                  setState(() {
                    /// Workaround to get an error color.
                    if (error == null) {
                      _codeError = false;
                    } else {
                      _codeError = true;
                    }
                  });
                  return error;
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              BasicTextField(
                hint: 'Gib deine E-Mail ein',
                label: 'E-Mail',
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validate: (value) => ValidationServices().validateEmail(value),
                onSaved: (value) => _controller!.add(ChangeEmail(value)),
              ),
              const SizedBox(height: 50),
              CMTextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    _controller!.add(RequestCodeCheck());
                  }
                },
                child: const Text("EINLADUNG PRÜFEN"),
                loading: _controller!.loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
