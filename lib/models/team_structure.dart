class TeamStructure {
  TeamStructure({
    required this.name,
    required this.id,
    this.url,
    this.localFilePath,
  });

  String name;
  String id;
  String? url;
  String? localFilePath;

  /// Currently only one version planned. Static file name makes replacing easier.
  static String storagePath = 'files/team-structure/most-recent';

  static TeamStructure fromJson(Map<String, dynamic> json, String id) {
    return TeamStructure(
      name: json['name'],
      id: id,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson([bool withId = false]) {
    assert(withId && url != null || !withId);
    return {
      if (withId) 'id': id,
      'name': name,
      'storagePath': storagePath,
      'url': url,
    };
  }
}
