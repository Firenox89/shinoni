import 'dart:ui';

abstract class Post {
  int get id;

  List<String> get tags;

  int get fileSize;

  String get previewUrl;

  int get previewWidth;

  int get previewHeight;

  String get sampleUrl;

  int get sampleWidth;

  int get sampleHeight;

  String get rating;

  int get width;

  int get height;
}

abstract class Tag {
  String get name;
  int get type;
  Color get color;

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

abstract class Booru {
  String get boardUrl;

  Future<List<Post>> requestFirstPage({String tag = ''});

  Future<List<Post>> requestNextPage({String tag = ''});

  Future<List<Post>> requestPage(int page, String tags);

  Future<List<Tag>> requestTags(String tag);

  Future<Color> requestTagColor(String name);
}
