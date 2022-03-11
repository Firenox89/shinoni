import 'dart:ui';

class Tag {
  final String name;
  final String board;
  final int id;
  final int count;
  final int type;
  final bool ambiguous;
  final Color color;

  Tag(this.name, this.board, this.id, this.count, this.type, this.ambiguous)
      : color = getColorForType(type);

  Tag.fromJson(this.board, Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        count = json['count'] as int,
        type = json['type'] as int,
        ambiguous = json['ambiguous'] as bool,
        color = getColorForType(json['type'] as int);
}

Color getColorForType(int type) {
  switch (type) {
    case 0:
      return Color(0xFFEE8887);
    case 1:
      return Color(0xFFCCCC00);
    case 3:
      return Color(0xFFDD00DD);
    case 4:
      return Color(0xFF00AA00);
    case 5:
      return Color(0xFF00BBBB);
    case 6:
      return Color(0xFFFF2020);
    default:
      return Color(0xFFEE8887);
  }
}
