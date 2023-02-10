import 'package:flutter/widgets.dart';

import '../data/api/booru.dart';

class TagText extends StatefulWidget {
  final Tag tag;
  final int size;

  TagText(this.tag, {Key? key, int? size})
      : size = size ?? 14,
        super(key: key);

  @override
  State<TagText> createState() => _TagTextState(tag, size);
}

class _TagTextState extends State<TagText> {
  final Tag tag;
  final int size;
  TextStyle style;

  var color = Color(0xFFEE8887);

  _TagTextState(this.tag, this.size)
      : style = TextStyle(fontSize: size.toDouble()) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    style = TextStyle(color: await tag.color, fontSize: size.toDouble());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      tag.name,
      style: style,
    );
  }
}
