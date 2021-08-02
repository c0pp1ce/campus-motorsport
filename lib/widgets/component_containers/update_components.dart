import 'package:campus_motorsport/models/components/component.dart';
import 'package:flutter/material.dart';

/// PageView where a user can add the updates to each selected component.
class UpdateComponents extends StatefulWidget {
  const UpdateComponents({
    required this.selectedComponents,
    required this.loadingListener,
    Key? key,
  })  : assert(selectedComponents.length != 0),
        super(key: key);

  final List<BaseComponent> selectedComponents;
  final void Function(bool) loadingListener;

  @override
  _UpdateComponentsState createState() => _UpdateComponentsState();
}

class _UpdateComponentsState extends State<UpdateComponents> {
  late final List<BaseComponent> copiedComponents;
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
    return Container();
  }

  Future<void> _copyList() async {
    // TODO : Switch to performant deep copy.
    final List<DateTime> times = [];
    times.add(DateTime.now());
    copiedComponents = List.empty(growable: true);
    for (final component in widget.selectedComponents) {
      if (component is ExtendedComponent) {
        copiedComponents.add(
          ExtendedComponent.fromJson(await component.toJson()),
        );
      } else {
        copiedComponents.add(
          BaseComponent.fromJson(await component.toJson()),
        );
      }
    }
    times.add(DateTime.now());
    print('Copy timer: ${times[1].difference(times[0]).inMilliseconds} ms.');
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {
        initialized = true;
      });
    });
  }
}
