import 'package:campus_motorsport/models/route_arguments/login_arguments.dart';
import 'package:campus_motorsport/widgets/layout/background_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_motorsport/controller/login_controller/login_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/widgets/snackbars/error_snackbar.dart';
import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/views/login/widgets/background_gradient.dart';
import 'package:campus_motorsport/views/login/widgets/form_fields.dart';
import 'package:campus_motorsport/views/login/widgets/logo.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/views/login/widgets/custom_divider.dart';
import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';

class LoginView extends StatefulWidget {
  final LoginArguments arguments;
  LoginView({this.arguments = const LoginArguments(fadeIn: true), Key? key})
      : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginController _loginController = LoginController();

  /// Key for the login form.
  final GlobalKey<FormState> _formKey = GlobalKey();

  /// Opacity of the screen content (except background gradient).
  double _opacity = 0.0;

  /// The background image of the view.
  final ImageProvider _image = AssetImage('assets/images/designer_edited.jpg');
  bool? _precached;

  @override
  void initState() {
    super.initState();

    /// Rebuild UI if _loginController notifies about changes.
    _loginController.addListener(() {
      setState(() {
        /// Show controller errors as snackbars.
        if (_loginController.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              _loginController.errorMessage!,
              'OK',
            ).buildSnackbar(context),
          );

          /// Hide error message if error is resolved (aka errorMessage == null)
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        /// Schedule navigation to home screen on successful login.
        if (_loginController.success) {
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            Navigator.of(context).pushReplacementNamed(homeRoute);
          });
        }
      });
    });

    /// Skip fade in.
    if (!widget.arguments.fadeIn) {
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
    if (widget.arguments.fadeIn && !_precached!) {
      precacheImage(_image, context).then((_) {
        setState(() {
          _opacity = 1.0;
          _precached = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: BackgroundGradient(
        drawGradient: !_precached!,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: BackgroundImage(
            image: _image,
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              alignment: Alignment.center,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      RepaintBoundary(
                        child: Logo(),
                      ),
                      const SizedBox(height: 50),
                      Form(
                        key: _formKey,
                        child: ChangeNotifierProvider.value(
                          value: _loginController,
                          child: FormFields(),
                        ),
                      ),
                      const SizedBox(height: 50),
                      CMTextButton(
                        child: const Text('LOGIN'),
                        loading: _loginController.loading,
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            /// Save inputs and perform http request.
                            _formKey.currentState?.save();
                            _loginController
                                .add(RequestLogin(Provider.of<TokenController>(
                              context,
                              listen: false,
                            )));
                          }
                        },
                      ),
                      CustomDivider(),
                      CMTextButton(
                        child: const Text('ACCOUNT ERSTELLEN'),
                        onPressed: () {
                          Navigator.pushNamed(context, registerRoute);
                        },
                        primary: ColorServices.darken(
                            Theme.of(context).colorScheme.onSurface, 10),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
