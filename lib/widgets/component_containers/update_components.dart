import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/components/vehicle_component.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:flutter/material.dart';

/// PageView where a user can add the updates to each selected component.
class UpdateComponents extends StatefulWidget {
  const UpdateComponents({
    required this.selectedComponents,
    required this.loadingListener,
    required this.currentContainer,
    Key? key,
  })  : assert(selectedComponents.length != 0),
        super(key: key);

  final List<BaseComponent> selectedComponents;
  final void Function(bool) loadingListener;
  final ComponentContainer currentContainer;

  @override
  _UpdateComponentsState createState() => _UpdateComponentsState();
}

class _UpdateComponentsState extends State<UpdateComponents> {
  late final List<BaseComponent> copiedComponents;
  final GlobalKey<FormState> _formKey = GlobalKey();
  int index = 0;
  bool initialized = false;

  @override
  void initState() {
    _copyList();
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
            //formKey: _formKey,  key per component if needed. NEEDED TODO
            key: ValueKey(index),
            fillWithData: true,
            read: false,
            component: copiedComponents[index],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: CMTextButton(
            child: Text(
              index == copiedComponents.length - 1 ? 'SPEICHERN' : 'WEITER',
            ),
            onPressed: () async {
              if(index < copiedComponents.length - 1) {
                await saveChanges();
                setState(() {
                  index++;
                });
                return;
              }
              await saveChanges();
              // TODO : Upload updates.
            },
          ),
        ),
      ],
    );
  }

  Future<void> saveChanges() async {
    print(await copiedComponents[index].toJson()); // TODO : Remove
    if(_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      print(await copiedComponents[index].toJson());
    }
  }

  /// Copies the selected components from current-state list if found there or else from
  /// the selected components itself so that their data can be changed without any
  /// side effects.
  Future<void> _copyList() async {
    // TODO : Switch to performant deep copy.
    //final List<DateTime> times = [];
    //times.add(DateTime.now());
    copiedComponents = List.empty(growable: true);
    for (final component in widget.selectedComponents) {
      if (component is ExtendedComponent) {
        final ExtendedComponent? fromCurrentState =
            _searchInCurrentState(component) as ExtendedComponent?;
        if (fromCurrentState != null) {
          copiedComponents.add(
            ExtendedComponent.fromJson(await fromCurrentState.toJson()),
          );
        } else {
          copiedComponents.add(
            ExtendedComponent.fromJson(await component.toJson()),
          );
        }
      } else {
        final BaseComponent? fromCurrentState =
            _searchInCurrentState(component);
        if (fromCurrentState != null) {
          copiedComponents.add(
            BaseComponent.fromJson(await fromCurrentState.toJson()),
          );
        } else {
          copiedComponents.add(
            BaseComponent.fromJson(await component.toJson()),
          );
        }
      }
    }
    //times.add(DateTime.now());
    //print('Copy timer: ${times[1].difference(times[0]).inMilliseconds} ms.');
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        initialized = true;
      });
    });
  }

  BaseComponent? _searchInCurrentState(BaseComponent component) {
    try {
      return widget.currentContainer.currentState
          .firstWhere((element) => element.component.id == component.id)
          .component;
    } on StateError {
      return null;
    }
  }
}
