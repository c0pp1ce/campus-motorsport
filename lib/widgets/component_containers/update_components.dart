import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// PageView where a user can add the updates to each selected component.
class UpdateComponents extends StatefulWidget {
  const UpdateComponents({
    required this.selectedComponents,
    required this.loadingListener,
    required this.successListener,
    required this.currentContainer,
    Key? key,
  })  : assert(selectedComponents.length != 0),
        super(key: key);

  final List<BaseComponent> selectedComponents;
  final void Function(bool) loadingListener;
  final void Function(bool) successListener;
  final ComponentContainer currentContainer;

  @override
  _UpdateComponentsState createState() => _UpdateComponentsState();
}

class _UpdateComponentsState extends State<UpdateComponents> {
  late final List<BaseComponent> copiedComponents;
  late final List<int?> eventCounters;
  late final List<GlobalKey<FormState>> _formKeys;
  int index = 0;
  bool initialized = false;

  @override
  void initState() {
    _copyList();
    _formKeys = List.generate(
      widget.selectedComponents.length,
      (index) => GlobalKey(),
      growable: false,
    );
    eventCounters = List.filled(widget.selectedComponents.length, null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration.zero,
          child: VehicleComponent(
            formKey: _formKeys[index],
            key: ValueKey(index),
            fillWithData: true,
            read: false,
            component: copiedComponents[index],
            previousData: _searchInCurrentState(copiedComponents[index]),
            onEventCounterSave: (value) {
              eventCounters[index] = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: CMTextButton(
            child: Text(
              index == copiedComponents.length - 1 ? 'SPEICHERN' : 'WEITER',
            ),
            onPressed: () async {
              if (index < copiedComponents.length - 1) {
                if (saveChanges(index)) {
                  setState(() {
                    index++;
                  });
                }
                return;
              }

              /// last component. Save and upload changes.
              if (saveChanges(index)) {
                uploadUpdates();
              }
            },
          ),
        ),
      ],
    );
  }

  bool saveChanges(int index) {
    if (_formKeys[index].currentState?.validate() ?? false) {
      _formKeys[index].currentState!.save();
      return true;
    }
    return false;
  }

  Future<void> uploadUpdates() async {
    widget.loadingListener(true);
    final DateTime updateTime = DateTime.now();
    final String updatedBy = context.read<CurrentUser>().user!.name;
    final List<Update> updates = List.empty(growable: true);
    int index = 0;
    for (final component in copiedComponents) {
      updates.add(Update(
        component: component,
        date: updateTime,
        by: updatedBy,
        eventCounter: eventCounters[index],
      ));
      index++;
    }

    final bool success = await CrudCompContainer().addUpdates(
      docId: widget.currentContainer.id!,
      updates: updates,
    );
    widget.loadingListener(false);
    if (!success) {
      widget.successListener(false);
      _showErrorDialog();
    } else {
      widget.successListener(true);
    }
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: 'Bitte überprüfe deine Verbindung.\n'
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

  /// Copies the selected components from
  /// the selected components themselves(they taken form the global components list based on id)
  /// so that their data can be changed without any side effects.
  Future<void> _copyList() async {
    // TODO : Switch to performant deep copy.
    copiedComponents = List.empty(growable: true);
    for (final component in widget.selectedComponents) {
      if (component is ExtendedComponent) {
        copiedComponents.add(
          ExtendedComponent.fromJson(await component.toJson(), component.id),
        );
      } else {
        copiedComponents.add(
          BaseComponent.fromJson(await component.toJson(), component.id),
        );
      }
    }
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        initialized = true;
      });
    });
  }

  Update? _searchInCurrentState(BaseComponent component) {
    try {
      return widget.currentContainer.currentState
          .firstWhere((element) => element.component.id == component.id);
    } on StateError {
      return null;
    }
  }
}
