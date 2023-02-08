import 'dart:ui';

abstract class Post {
  List<Tag> get tags;

  String get board;

  String get fileUrl;

  String get previewUrl;

  String get rating;

  String get sampleUrl;

  String? get source;

  int get fileSize;

  int get height;

  int get id;

  int get previewHeight;

  int get previewWidth;

  int get sampleHeight;

  int get sampleWidth;

  int get width;
}

abstract class Tag {
  String get name;

  Future<int> get type;

  Future<Color> get color => getColorForType(type);
}

class OfflineTag extends Tag {
  @override
  final String name;
  final int loadedType;

  @override
  Future<int> get type => Future.value(loadedType);

  OfflineTag(this.name, this.loadedType);
}

Future<Color> getColorForType(Future<int> type) async {
  switch (await type) {
    case -1:
      return Color(0xFF000000);
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

  bool get hasLogin => false;

  bool get canSave => false;

  bool get canDelete => false;

  Future<List<Post>> requestFirstPage({String tag = ''});

  Future<List<Post>> requestNextPage({String tag = ''});

  Future<List<Post>> requestPage(int page, String tags);

  Future<List<Tag>> requestTags(String tag);

  Future<void> savePost(Post post);

  Future<void> deletePost(Post post);
}
