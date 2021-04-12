import 'package:campus_motorsport/utils/size_config.dart';
import 'package:flutter/material.dart';

import 'package:campus_motorsport/widgets/buttons/cm_text_button.dart';

/// The root of the registration screen.
class RegistrationView extends StatefulWidget {

  RegistrationView({Key? key}) : super(key: key);

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  /// Key for the registration form.
  //final GlobalKey<FormState> _formKey = GlobalKey();

  Widget? _currentFormWidget;

  @override
  void initState() {
    super.initState();
    // TODO: implement error snackbars
    _currentFormWidget = Column(
      children: [
        const Text("PIN Feld"),
        const Text("Email Feld"),
        CMTextButton(
          onPressed: () {
            _switchFormWidget(context);
          },
          child: const Text("Check"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
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
            padding: const EdgeInsets.all(30.0),
            child: AnimatedSwitcher(
              child: _currentFormWidget,
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  child: child,
                  scale: animation,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  _switchFormWidget(BuildContext context) {
    setState(() {
      _currentFormWidget = Container(
        child: Column(
          children: [
            const Text("My email"),
            const Text("My Name"),
            const Text("My password"),
            CMTextButton(
              onPressed: () {},
              child: const Text("ACCOUNT ERSTELLEN"),
            ),
          ],
        ),
      );
    });
  }
}
