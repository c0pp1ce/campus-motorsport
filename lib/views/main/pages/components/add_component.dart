import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/provider/components/components_provider.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';

class AddComponent extends StatefulWidget {
  const AddComponent({Key? key}) : super(key: key);

  @override
  _AddComponentState createState() => _AddComponentState();
}

class _AddComponentState extends State<AddComponent> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<CMDropDownMenuState> _categoryKey = GlobalKey();
  final GlobalKey<VehicleComponentState> _vehicleKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      appbarTitle: const Text('Komponente erstellen'),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Komponente erstellen',
        ),
      ),
      actions: _loading
          ? [
              Container(
                height: 50,
                width: 55,
                padding: const EdgeInsets.all(SizeConfig.basePadding),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            ]
          : [
              IconButton(
                onPressed: () {
                  setState(() {
                    _reset();
                  });
                },
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
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    setState(() {
                      _loading = true;
                      _vehicleKey.currentState?.loading = true;
                    });
                    final bool success = await _save(context);
                    setState(() {
                      _loading = false;
                      _vehicleKey.currentState?.loading = false;
                    });
                    if (success) {
                      setState(() {
                        _reset();
                      });
                    } else {
                      _showErrorDialog();
                    }
                  }
                },
                icon: Icon(
                  LineIcons.save,
                  size: 30,
                ),
                splashRadius: SizeConfig.iconButtonSplashRadius,
              ),
            ],
      offsetBeforeTitleShown: 70,
      body: VehicleComponent(
        key: _vehicleKey,
        create: true,
        read: false,
        fillWithData: false,
        nameController: _nameController,
        categoryKey: _categoryKey,
        formKey: _formKey,
      ),
    );
  }

  void _reset() {
    _nameController.clear();
    _categoryKey.currentState?.reset();
    _vehicleKey.currentState?.reset();
  }

  /// Form is saved before.
  Future<bool> _save(BuildContext context) async {
    BaseComponent baseComponent = BaseComponent(
      name: _vehicleKey.currentState!.name!,
      state: ComponentStates.newComponent,
      category: _vehicleKey.currentState!.category!,
    );

    if (_vehicleKey.currentState!.additionalData.isNotEmpty) {
      baseComponent = ExtendedComponent.fromBaseComponent(
        baseComponent: baseComponent,
        additionalData: _vehicleKey.currentState!.additionalData,
      );
    }

    final CrudComponent crudComponent = CrudComponent();
    final bool success =
        await crudComponent.createComponent(component: baseComponent);
    if (success) {
      context.read<ComponentsProvider>().addComponent(baseComponent);
    }
    return success;
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
