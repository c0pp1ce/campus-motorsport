import 'package:campus_motorsport/controller/login_controller/login_controller.dart';
import 'package:campus_motorsport/controller/login_controller/login_event.dart';
import 'package:campus_motorsport/controller/token_controller/token_controller.dart';
import 'package:campus_motorsport/widgets/snackbars/error_snackbar.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/views/login/widgets/background_gradient.dart';
import 'package:campus_motorsport/views/login/widgets/background_image.dart';
import 'package:campus_motorsport/views/login/widgets/form_fields.dart';
import 'package:campus_motorsport/views/login/widgets/logo.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/views/login/widgets/custom_divider.dart';
import 'package:campus_motorsport/widgets/buttons/gradient_text_button.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

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
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    /// Play fade in animation when bg image is precached.
    /// Cannot be done in the initState() as that can lead to an an error.
    precacheImage(_image, context).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: BackgroundGradient(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(milliseconds: 800),
          child: BackgroundImage(
            image: _image,
            child: Container(
              width: SizeConfig.screenWidth,
              height: SizeConfig.screenHeight,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 50.0, horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      Logo(),
                      SizedBox(height: 80),
                      Form(
                        key: _formKey,
                        child: ChangeNotifierProvider.value(
                          value: _loginController,
                          child: FormFields(),
                        ),
                      ),
                      SizedBox(height: 80),
                      GradientTextButton(
                        child: Text('LOGIN'),
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
                      GradientTextButton(
                        child: Text('ACCOUNT ERSTELLEN'),
                        onPressed: () {},
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
