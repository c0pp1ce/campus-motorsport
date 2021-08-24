import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/component_containers/cc_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_image_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class AddContainer extends StatefulWidget {
  const AddContainer({Key? key}) : super(key: key);

  @override
  _AddContainerState createState() => _AddContainerState();
}

class _AddContainerState extends State<AddContainer> {
  bool _loading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<CMDropDownMenuState> _categoryKey = GlobalKey();

  String name = '';
  ComponentContainerTypes type = ComponentContainerTypes.vehicle;
  CMImage image = CMImage();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      name = '';
      type = ComponentContainerTypes.vehicle;
      image = CMImage();
      _nameController.clear();
      _categoryKey.currentState?.currentValue = type.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      appbarTitle: Text(
        'Fahrzeug/Lager erstellen',
        style: Theme.of(context).textTheme.headline6,
      ),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Fahrzeug/Lager erstellen',
        ),
      ),
      offsetBeforeTitleShown: 60,
      actions: _loading
          ? [
              Container(
                height: 50,
                width: 55,
                padding: const EdgeInsets.all(SizeConfig.basePadding),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ]
          : _buildAppBarActions(context),
      body: _buildBody(context),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        onPressed: _reset,
        icon: Icon(
          LineIcons.trash,
          color: ColorServices.darken(
            Theme.of(context).colorScheme.secondary,
            20,
          ),
        ),
        splashRadius: SizeConfig.iconButtonSplashRadius,
      ),
      const SizedBox(
        width: SizeConfig.basePadding,
      ),
      IconButton(
        onPressed: _save,
        icon: Icon(
          LineIcons.save,
          size: 30,
        ),
        splashRadius: SizeConfig.iconButtonSplashRadius,
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SizeConfig.basePadding,
      ).add(
        EdgeInsets.only(bottom: SizeConfig.basePadding),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            CMImagePicker(
              imageFile: image,
              heroTag: 'ContainerCreationImagePicker',
            ),
            const SizedBox(
              height: SizeConfig.basePadding,
            ),
            CMTextField(
              controller: _nameController,
              label: 'Name',
              maxLines: 1,
              textInputType: TextInputType.text,
              textInputAction: TextInputAction.done,
              validate: (value) => Validators().validateNotEmpty(
                value,
                'Name',
              ),
              onSaved: (value) {
                name = value ?? '';
              },
            ),
            const SizedBox(
              height: SizeConfig.basePadding * 2,
            ),
            CMDropDownMenu(
              key: _categoryKey,
              values:
                  ComponentContainerTypes.values.map((e) => e.name).toList(),
              initialValue: type.name,
              onSelect: (value) {
                setState(() {
                  for (final myType in ComponentContainerTypes.values) {
                    if (myType.name == value) {
                      type = myType;
                      break;
                    }
                  }
                });
              },
              label: 'Typ',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
      });
      final bool success = await CrudCompContainer().createContainer(
        componentContainer: ComponentContainer(
          name: name,
          type: type,
          image: image,
        ),
      );
      setState(() {
        _loading = false;
      });
      if (success) {
        switch (type) {
          case ComponentContainerTypes.stock:
            context.read<StocksProvider>().reload(false);
            break;
          case ComponentContainerTypes.vehicle:
            context.read<VehiclesProvider>().reload(false);
            break;
        }
        _reset();
      } else {
        _showErrorDialog();
      }
    }
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: 'Bitte überprüfe die Verbindung und versuche es erneut.\n'
          'Bleibt der Fehler bestehen wende dich an die IT.',
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
