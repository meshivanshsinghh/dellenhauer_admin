class CoursesModel {
  String? id;
  String? name;
  String? description;
  bool? isActive;

  CoursesModel({this.description, this.id, this.isActive, this.name});
  // from map
  CoursesModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return;
    id = map['id'];
    name = map['name'];
    description = map['description'];
    isActive = map['isActive'] ?? false;
  }
  // to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}
