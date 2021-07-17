import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/background/background_image.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

/// View to deal with occurring login problems such as the need to resend the
/// verification email.
class LoginProblems extends StatefulWidget {
  const LoginProblems({
    required this.backgroundImage,
    Key? key,
  }) : super(key: key);

  final ImageProvider backgroundImage;

  @override
  _LoginProblemsState createState() => _LoginProblemsState();
}

class _LoginProblemsState extends State<LoginProblems> {
  String? _email;
  String? _password;
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !_loading;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !_loading,
          title: Text('Problembehandlung'),
          elevation: SizeConfig.baseBackgroundElevation,
        ),
        body: BackgroundImage(
          image: widget.backgroundImage,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(SizeConfig.basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionTitle('E-Mail Verifikation'),
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
                const Text(
                  'Damit dir eine weitere E-Mail zur Verifizierung gesendet werden kann '
                  'musst du hier deine Anmeldedaten eingeben.',
                ),
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
                _buildAuthLogin(),
                const SizedBox(
                  height: SizeConfig.basePadding,
                ),
                CMTextButton(
                  loading: _loading,
                  child: Text(
                    'E-MAIL SENDEN',
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      assert(
                        _email != null && _password != null,
                        'Validator did not check for null.',
                      );
                      final CMAuth auth = CMAuth();

                      /// Perform auth login
                      setState(() {
                        _loading = true;
                      });
                      final bool loggedIn =
                          await auth.loginToAuth(_email!, _password!);
                      bool emailSent = false;
                      if (loggedIn) {
                        /// Resend email
                        emailSent = await auth.sendVerificationEmail();
                        await auth.signOut();
                      }
                      setState(() {
                        _loading = false;
                      });
                      if (!loggedIn || !emailSent) {
                        _showErrorDialog();
                      } else {
                        _showSuccessDialog();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthLogin() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CMTextField(
            hint: 'Gib deine E-Mail ein',
            label: 'E-Mail',
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            validate: (value) => Validators().validateEmail(value),
            onSaved: (value) {
              _email = value;
            },
          ),
          const SizedBox(
            height: SizeConfig.basePadding * 2,
          ),
          CMTextField(
            hint: 'Gib dein Passwort ein',
            label: 'Passwort',
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.text,
            toggleObscure: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            validate: (value) =>
                Validators().validateNotEmpty(value, 'Passwort'),
            onSaved: (value) {
              _password = value;
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Senden fehlgeschlagen.',
      text: 'Bitte überprüfe die eigegebenen Daten und '
          'Warte etwas, bevor du es erneut probierst.\n'
          'Sollten die Probleme bestehen bleiben wende dich an die IT.',
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
      title: 'Email versendet.',
      text: 'Dir wurde ein Link zur Verifizierung deiner E-Mail geschickt.',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
