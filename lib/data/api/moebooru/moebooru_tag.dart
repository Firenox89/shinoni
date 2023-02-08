import '../booru.dart';

class MoebooruTag extends Tag {
  @override
  final String name;
  int? loadedType;
  Function? typeLoader;

  @override
  Future<int> get type => getType();

  MoebooruTag(this.name, this.typeLoader);

  MoebooruTag.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        loadedType = json['type'] as int;

  Future<int> getType() async {
    if (loadedType != null) {
      return Future.value(loadedType!);
    } else {
      return (await typeLoader!.call(name)) as int;
    }
  }
}
