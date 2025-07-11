import 'package:hive/hive.dart';

part 'project_model.g.dart'; // Needed for code generation

@HiveType(typeId: 1)
class Project extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int? color;

  Project({required this.name, this.color});
}
