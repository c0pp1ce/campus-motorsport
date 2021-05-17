import 'package:campus_motorsport/widgets/general/snackbars/error_snackbar.dart';
import 'package:campus_motorsport/widgets/general/style/background_gradient.dart';
import 'package:campus_motorsport/widgets/general/style/background_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campus_motorsport/models/route_arguments/login_arguments.dart';
import 'package:campus_motorsport/controller/login_controller/login_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/widgets/login/form_fields.dart';
import 'package:campus_motorsport/widgets/login/logo.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/widgets/login/custom_divider.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';

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
      this._listener();
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
  void dispose() {
    super.dispose();
    _loginController.removeListener(() {
      this._listener();
    });
    _loginController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: SafeArea(
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
                            if (_loginController.loading) {
                              _loginController.add(RequestCancelLogin());
                            }
                            Navigator.pushNamed(context, registerRoute,
                                arguments: _image);
                          },
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

  /// Reacts to controller changes.
  void _listener() {
    if (!mounted) return;
    setState(() {
      /// Show controller errors as snackbars.
      if (_loginController.errorMessage != null &&
          !_loginController.cancelRequest) {
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
      if (_loginController.success && !_loginController.cancelRequest) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          Navigator.of(context).pushReplacementNamed(homeRoute);
        });
      }
    });
  }
}
