import 'dart:ui';

import '../booru.dart';

class SzurubooruTag extends Tag {
  final String board;

  @override
  // TODO: implement color
  Color get color => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement type
  int get type => throw UnimplementedError();

  SzurubooruTag.fromJson(this.board, Map<String, dynamic> json) {
  }
}