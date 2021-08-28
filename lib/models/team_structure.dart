import 'package:cloud_firestore/cloud_firestore.dart';

class TeamStructure {
  TeamStructure({
    required this.name,
    required this.id,
    required this.latestUpdate,
    this.url,
    this.localFilePath,
  });

  String name;
  String id;
  String? url;
  String? localFilePath;
  DateTime latestUpdate;

  /// Currently only one version planned. Static file name makes replacing easier.
  static String storagePath = 'files/team-structure/most-recent';

  static TeamStructure fromJson(Map<String, dynamic> json, String id) {
    if (json['latestUpdate'] is String) {
      json['latestUpdate'] = DateTime.parse(json['latestUpdate']).toLocal();
    } else {
      json['latestUpdate'] =
          (json['latestUpdate'] as Timestamp).toDate().toLocal();
    }
    return TeamStructure(
      name: json['name'],
      id: id,
      url: json['url'],
      latestUpdate: json['latestUpdate'],
    );
  }

  Map<String, dynamic> toJson([bool withId = false]) {
    assert(withId && url != null || !withId);
    return {
      if (withId) 'id': id,
      'name': name,
      'storagePath': storagePath,
      'url': url,
      'latestUpdate': latestUpdate.toUtc(),
    };
  }
}
