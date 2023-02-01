import 'dart:ui';

import '../booru.dart';

class MoebooruTag extends Tag {
  final String name;
  final String board;
  final int id;
  final int count;
  final int type;
  final bool ambiguous;
  final Color color;

  MoebooruTag(this.name, this.board, this.id, this.count, this.type, this.ambiguous)
      : color = getColorForType(type);

  MoebooruTag.fromJson(this.board, Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        count = json['count'] as int,
        type = json['type'] as int,
        ambiguous = json['ambiguous'] as bool,
        color = getColorForType(json['type'] as int);
}
