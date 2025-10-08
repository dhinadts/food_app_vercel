class Food {
  final int id;
  final String name;
  final String description;
  final List<String> tags;
  Food({required this.id, required this.name, required this.description, required this.tags});

  factory Food.fromMap(Map m) => Food(id: m['id'], name: m['name'] ?? '', description: m['description'] ?? '', tags: List<String>.from(m['tags'] ?? []));
  Map toMap() => {'id':id,'name':name,'description':description,'tags':tags};
}
