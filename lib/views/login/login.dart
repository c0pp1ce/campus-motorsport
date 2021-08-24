import 'package:campus_motorsport/models/user.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/cm_auth.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/background/background_gradient.dart';
import 'package:campus_motorsport/widgets/general/background/background_image.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/login/cm_divider.dart';
import 'package:campus_motorsport/widgets/login/cm_logo.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({
    this.fadeIn = true,
    Key? key,
  }) : super(key: key);

  /// Given via route arguments. Determines if the background image should be
  /// faded in.
  final bool fadeIn;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /// Key for the login form.
  final GlobalKey<FormState> _formKey = GlobalKey();

  /// Opacity of the screen content (except background gradient).
  double _opacity = 0.0;

  /// The background image of the view.
  final ImageProvider _image = AssetImage('assets/images/designer_edited.jpg');
  late bool _precached;

  // User data.
  String? _email;
  String? _password;

  /// Used when performing login.
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    /// Skip fade in.
    if (!widget.fadeIn) {
      _opacity = 1.0;
      _precached = true;
    } else {
      _precached = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Play fade in animation when bg image is precached.
    /// Cannot be done in the initState() as that can lead to an an error.
    if (widget.fadeIn && !_precached) {
      precacheImage(_image, context).then((_) {
        setState(() {
          _opacity = 1.0;
          _precached = true;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundGradient(
        drawGradient: !_precached,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: BackgroundImage(
            image: _image,
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              alignment: Alignment.center,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(SizeConfig.basePadding * 2),
                    child: Column(
                      children: <Widget>[
                        RepaintBoundary(
                          child: CMLogo(),
                        ),
                        const SizedBox(
                          height: SizeConfig.basePadding * 4,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              CMTextField(
                                hint: 'Gib deine E-Mail ein',
                                label: 'E-Mail',
                                textInputType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.4),
                                validate: (value) =>
                                    Validators().validateEmail(value),
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
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.4),
                                validate: (value) => Validators()
                                    .validateNotEmpty(value, 'Passwort'),
                                onSaved: (value) {
                                  _password = value;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: SizeConfig.basePadding * 4,
                        ),
                        CMTextButton(
                          child: const Text('LOGIN'),
                          loading: _loading,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              /// Save inputs and perform http request.
                              _formKey.currentState?.save();
                              assert(
                                _email != null && _password != null,
                                'Validator did not check for null.',
                              );
                              setState(() {
                                _loading = true;
                              });
                              final User? user = await CMAuth()
                                  .login(email: _email!, password: _password!);
                              setState(() {
                                _loading = false;
                              });
                              if (user == null) {
                                _showErrorDialog();
                              } else {
                                context.read<CurrentUser>().user = user;
                                Navigator.of(context).pushReplacementNamed(
                                  mainRoute,
                                );
                              }
                            }
                          },
                        ),
                        CMDivider(),
                        _buildGreyButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              registerRoute,
                              arguments: _image,
                            );
                          },
                          child: const Text('ACCOUNT ERSTELLEN'),
                        ),
                        const SizedBox(
                          height: SizeConfig.basePadding,
                        ),
                        _buildGreyButton(
                            child: const Text('OFFLINE MODUS'),
                            disabled: false,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                offlineRoute,
                              );
                            }),
                        const SizedBox(
                          height: SizeConfig.basePadding,
                        ),
                        _buildGreyButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              loginProblemsRoute,
                              arguments: _image,
                            );
                          },
                          child: const Text('PROBLEME BEI DER ANMELDUNG'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreyButton({
    void Function()? onPressed,
    required Widget child,
    bool disabled = false,
  }) {
    return CMTextButton(
      child: child,
      onPressed: _loading ? null : onPressed,
      primary: !disabled ? Theme.of(context).colorScheme.onSurface : null,
      gradient: LinearGradient(
        colors: <Color>[
          ColorServices.brighten(
            Theme.of(context).colorScheme.surface.withOpacity(0.7),
            25,
          ),
          Theme.of(context).colorScheme.surface.withOpacity(0.9),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Login fehlgeschlagen.',
      text: 'Bitte überprüfe die eigegebenen Daten.\n'
          'Beachte zudem, dass du deine E-Mail verifizieren und durch einen Administrator bestätigt werden muss.',
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
}
