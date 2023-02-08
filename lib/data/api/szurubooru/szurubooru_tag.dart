import 'dart:ui';

import '../booru.dart';

class SzurubooruTag extends Tag {
  final String board;
  final String name;
  final int loadedType;
  Future<int> get type => Future.value(loadedType);

  SzurubooruTag.fromJson(this.board, Map<String, dynamic> json)
      : name = json['names'][0] as String,
        loadedType = int.parse(json['category'] as String);
}
