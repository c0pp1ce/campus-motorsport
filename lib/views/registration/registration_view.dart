import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/routes/routes.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/views/registration/widgets/code_check.dart';
import 'package:campus_motorsport/views/registration/widgets/user_data.dart';
import 'package:campus_motorsport/widgets/snackbars/error_snackbar.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

/// The root of the registration screen.
class RegistrationView extends StatefulWidget {
  RegistrationView({Key? key}) : super(key: key);

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  RegistrationController? _controller;

  Widget? _currentFormWidget;

  @override
  void initState() {
    super.initState();

    _controller = RegistrationController();
    _controller!.addListener(() {
      this._listener();
    });

    _currentFormWidget = CodeCheck(
      switchForm: _switchFormWidget,
    );
  }

  @override
  void dispose() {
    _controller!.removeListener(() {
      this._listener();
    });
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 10.0,
        title: const Text('Account erstellen'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: WillPopScope(
              onWillPop: () async {
                if (_controller!.loading) {
                  _controller!.add(RequestCancelRequest());
                }
                return true;
              },
              child: ChangeNotifierProvider.value(
                value: _controller!,
                child: AnimatedSwitcher(
                  child: _currentFormWidget,
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      child: child,
                      scale: animation,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Reacts to changes in the controller.
  void _listener() {
    /// Dont call setState on unmounted widgets.
    if(!mounted) return;
    /// Rebuild UI on controller changes.
    if (!(_controller?.cancelRequest ?? true)) {
      setState(() {
        /// Show controller errors as snackbars.
        if (_controller!.errorMessage != null &&
            !_controller!.cancelRequest) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              _controller!.errorMessage!,
              'OK',
              backgroundColor: ColorServices.brighten(
                  Theme.of(context).colorScheme.surface, 8),
            ).buildSnackbar(context),
          );
        } else {
          /// Hide error message if error is resolved (aka errorMessage == null)
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        /// Schedule navigation to home screen on successful registration.
        if (_controller!.success && !_controller!.cancelRequest) {
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            Navigator.of(context).pushReplacementNamed(homeRoute);
          });
        }
      });
    }
  }

  _switchFormWidget() {
    setState(() {
      _currentFormWidget = UserData();
    });
  }
}
