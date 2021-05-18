import 'package:campus_motorsport/controller/registration_controller/registration_controller.dart';
import 'package:campus_motorsport/controller/registration_controller/registration_event.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utils/size_config.dart';
import 'package:campus_motorsport/widgets/general/snackbars/error_snackbar.dart';
import 'package:campus_motorsport/widgets/general/style/background_image.dart';
import 'package:campus_motorsport/widgets/registration/user_data.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The root of the registration screen.
class RegistrationView extends StatefulWidget {
  final ImageProvider backgroundImage;

  RegistrationView(this.backgroundImage, {Key? key}) : super(key: key);

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  late RegistrationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = RegistrationController();
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      body: BackgroundImage(
        image: widget.backgroundImage,
        child: Container(
          width: SizeConfig.screenWidth,
          height: SizeConfig.screenHeight,
          alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: WillPopScope(
                  onWillPop: () async {
                    if (_controller.loading) {
                      _controller.add(RequestCancelRequest());
                    }
                    return true;
                  },
                  child: ChangeNotifierProvider.value(
                    value: _controller,
                    child: UserData(),
                  ),
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
    if (!mounted) return;

    /// Rebuild UI on controller changes.
    if (!(_controller.cancelRequest)) {
      setState(() {
        /// Show controller errors as snackbars.
        if (_controller.errorMessage != null && !_controller.cancelRequest) {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(
              _controller.errorMessage!,
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
        if (_controller.success && !_controller.cancelRequest) {
          WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
            Navigator.of(context).pop();
          });
        }
      });
    }
  }
}
