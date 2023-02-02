import 'dart:ui';

import '../booru.dart';

class SzurubooruTag extends Tag {
  final String board;
  final String name;
  final int type;

  @override
  Color get color => getColorForType(type);

  SzurubooruTag.fromJson(this.board, Map<String, dynamic> json)
      : name = json['names'][0] as String,
        type = int.parse(json['category'] as String);
}
