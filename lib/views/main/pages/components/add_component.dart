import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/models/vehicle_components/data_input.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_component.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/components/component_category.dart';
import 'package:campus_motorsport/widgets/general/components/component_date.dart';
import 'package:campus_motorsport/widgets/general/components/component_image.dart';
import 'package:campus_motorsport/widgets/general/components/component_number.dart';
import 'package:campus_motorsport/widgets/general/components/component_state.dart';
import 'package:campus_motorsport/widgets/general/components/create_data_input.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/general/components/component_text.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AddComponent extends StatefulWidget {
  const AddComponent({Key? key}) : super(key: key);

  @override
  _AddComponentState createState() => _AddComponentState();
}

class _AddComponentState extends State<AddComponent> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<CMDropDownMenuState> _categoryKey = GlobalKey();
  bool _loading = false;

  String? name;
  ComponentCategories? category;
  final TextEditingController _nameController = TextEditingController();
  List<DataInput> additionalData = [];

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
                    });
                    final bool success = await _save();
                    setState(() {
                      _loading = false;
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
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeConfig.basePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Hinweis: ',
                  ),
                  Expanded(
                    child: Text(
                      'Datum und Durchführer einer Wartung werden nicht in der Komponente gespeichert. '
                      'Ein Datenfeld ist dafür also nicht nötig.',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
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
                  name = value;
                },
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              ComponentCategory(
                onSaved: (value) {
                  for (final ComponentCategories c
                      in ComponentCategories.values) {
                    if (c.name == value) {
                      setState(() {
                        category = c;
                      });
                      break;
                    }
                  }
                },
                enabled: true,
                dropDownKey: _categoryKey,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              ComponentState(
                onSaved: (_) {},
                enabled: false,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              _buildAdditionalData(context),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              Center(
                child: SizedBox(
                  width: SizeConfig.screenWidth / 2,
                  child: CMTextButton(
                    loading: _loading,
                    child: Icon(
                      LineIcons.plus,
                      size: 35,
                    ),
                    onPressed: () async {
                      final DataInput? dataInput =
                          await _showTypeSelection(context);
                      if (dataInput != null) {
                        setState(() {
                          additionalData.add(dataInput);
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalData(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: additionalData.map((dataInput) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: _getDataInputWidget(dataInput),
            ),
            IconButton(
              icon: Icon(
                LineIcons.trash,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                setState(() {
                  additionalData.remove(dataInput);
                });
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _getDataInputWidget(DataInput dataInput) {
    switch (dataInput.type) {
      case InputTypes.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentText(
            dataInput: dataInput,
            enabled: false,
          ),
        );
      case InputTypes.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentNumber(
            dataInput: dataInput,
            enabled: false,
          ),
        );
      case InputTypes.date:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentDate(
            dataInput: dataInput,
            enabled: false,
          ),
        );
      case InputTypes.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentImage(
            dataInput: dataInput,
            enabled: false,
          ),
        );
    }
  }

  Future<DataInput?> _showTypeSelection(BuildContext context) {
    return showModalBottomSheet<DataInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: SizeConfig.baseBackgroundElevation,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.baseBorderRadius),
          topRight: Radius.circular(SizeConfig.baseBorderRadius),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: CreateDataInput(
            onSave: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );
  }

  void _reset() {
    name = null;
    _nameController.clear();
    additionalData = [];
    _categoryKey.currentState?.reset();
  }

  /// Form is saved before.
  Future<bool> _save() async {
    BaseComponent baseComponent = BaseComponent(
      name: name!,
      state: ComponentStates.newComponent,
      category: category!,
    );

    if (additionalData.isNotEmpty) {
      baseComponent = ExtendedComponent.fromBaseComponent(
          baseComponent: baseComponent, additionalData: additionalData);
    }

    final CrudComponent crudComponent = CrudComponent();
    return crudComponent.createComponent(component: baseComponent);
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
