import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/component_containers/event.dart';
import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';

enum ComponentContainerTypes {
  stock,
  vehicle,
}

extension ComponentContainerTypeNames on ComponentContainerTypes {
  String get name {
    switch (this) {
      case ComponentContainerTypes.stock:
        return 'Lager';
      case ComponentContainerTypes.vehicle:
        return 'Fahrzeug';
    }
  }
}

/// Contains a list of components as well as a list of updates which are based
/// off of the components.
/// The current state is represented by the most recent
/// update to each component.
class ComponentContainer {
  ComponentContainer({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.updates = const [],
    this.currentState = const [],
    this.components = const [],
    this.events = const [],
  });

  /// This constructor is only used for creating a new component which therefore
  /// cannot posses an ID. Dont use it for any other purpose.
  ComponentContainer.withoutId({
    required this.name,
    required this.type,
    this.image,
    this.updates = const [],
    this.currentState = const [],
    this.components = const [],
    this.events = const [],
  }) : id = '';

  /// Document id.
  String id;
  String name;
  ComponentContainerTypes type;
  CMImage? image;

  List<Update> updates;
  List<Update> currentState;
  List<Event> events;

  /// List of component (document)ids by which each component can be retrieved.
  List<String> components;

  /// Sorts the current-state list.
  /// Reverts the updates and events lists so that newer updates are first.
  static ComponentContainer fromJson(Map<String, dynamic> json, String id) {
    /// Get type.
    final String typeName = json['type'];
    late ComponentContainerTypes type;
    if (typeName == ComponentContainerTypes.vehicle.name) {
      type = ComponentContainerTypes.vehicle;
    } else {
      type = ComponentContainerTypes.stock;
    }

    final List<Update> updates = List.empty(growable: true);
    final List<Update> currentState = List.empty(growable: true);
    final List<Event> events = List.empty(growable: true);
    final List<String> components =
        (json['components'] as List?)?.cast<String>() ??
            List.empty(growable: true);

    for (final update
        in (json['updates'] as List? ?? []).cast<Map<String, dynamic>>()) {
      updates.add(Update.fromJson(update));
    }
    for (final update
        in (json['currentState'] as List? ?? []).cast<Map<String, dynamic>>()) {
      currentState.add(Update.fromJson(update));
    }

    for (final event
        in (json['events'] as List? ?? []).cast<Map<String, dynamic>>()) {
      events.add(Event.fromJson(event));
    }

    sortCurrentStateList(currentState);

    return ComponentContainer(
      id: id,
      name: json['name'],
      type: type,
      image: (json['image'] as String?)?.isNotEmpty ?? false
          ? CMImage.fromUrl(json['image'])
          : null,
      updates: updates.reversed.toList(),
      currentState: currentState,
      components: components,
      events: events.reversed.toList(),
    );
  }

  Future<Map<String, dynamic>> toJson(String folder) async {
    /// No need to store id as it is the document it.
    final json = <String, dynamic>{
      'name': name,
      'type': type.name,
    };

    if (image?.imageProvider != null) {
      await image!.uploadImageToFirebaseStorage(folder);
      assert(image?.url != null, 'Upload failed or no URL stored');
      json['image'] = image!.url;
    }

    json['updates'] = List.empty(growable: true);
    for (final update in updates) {
      (json['updates'] as List).add(await update.toJson(id));
    }

    json['currentState'] = List.empty(growable: true);
    for (final update in currentState) {
      (json['currentState'] as List).add(await update.toJson(id));
    }

    json['events'] = List.empty(growable: true);
    for (final event in events) {
      (json['events'] as List).add(event.toJson());
    }

    json['components'] = components;

    return json;
  }

  static void sortCurrentStateList(List<Update> currentState) {
    if (currentState.isEmpty) {
      return;
    }
    currentState.sort((a, b) {
      return BaseComponent.compareComponents(a.component, b.component);
    });
  }
}
