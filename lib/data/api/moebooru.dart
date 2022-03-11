import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util.dart';
import '../db/db.dart';
import '../model/post.dart';
import '../model/tag.dart';

const limit = 20;

class Moebooru {
  final dio = Dio(BaseOptions());
  final String boardUrl;
  final DB db;
  SharedPreferences prefs;

  var currentPage = 0;

  Moebooru(this.boardUrl, this.prefs, this.db);

  Future<List<PostModel>> requestFirstPage({String tag = ''}) {
    logD('Request first page');
    currentPage = 0;
    return requestNextPage(tag: tag);
  }

  Future<List<PostModel>> requestNextPage({String tag = ''}) {
    logD('Request next page');
    return requestPage(++currentPage, tag);
  }

  Future<List<PostModel>> requestPage(int page, String tags) async {
    final request = '$boardUrl/post.json?limit=$limit' +
        ((page > 1) ? '&page=$page' : '') +
        ((tags != '') ? '&tags=$tags' : '');

    logD(request);
    var res = await dio.get<List<dynamic>>(request);
    var posts = (res.data as List<dynamic>)
        .map((dynamic x) => PostModel.fromJson(x as Map<String, dynamic>))
        .toList();

    if (!prefs.inclSafe) {
      posts.removeWhere((post) => post.rating == 's');
    }
    if (!prefs.inclQuestionable) {
      posts.removeWhere((post) => post.rating == 'q');
    }
    if (!prefs.inclExplicit) {
      posts.removeWhere((post) => post.rating == 'e');
    }
    return posts;
  }

  Future<List<Tag>> requestTags(String tag) async {
    if (tag.length < 3) {
      return [];
    }
    final request = '$boardUrl/tag.json?name=$tag&limit=0';

    logD(request);
    var res = await dio.get<List<dynamic>>(request);
    var tags = (res.data as List<dynamic>)
        .map((dynamic x) => Tag.fromJson(boardUrl, x as Map<String, dynamic>))
        .toList();
    _cacheTagColors(tags);
    var copy = tags.toList();
    copy.removeWhere((element) => element.name.startsWith(tag));
    tags.removeWhere((element) => !element.name.startsWith(tag));
    return tags + copy;
  }

  void _cacheTagColors(List<Tag> tags) {
    for (final tag in tags) {
      db.storeTagType(tag);
    }
  }

  Future<Color> requestTagColor(String name) async {
    var fromCache = db.getTagType(name);
    if (fromCache == null) {
      await requestTags(name);
      fromCache = db.getTagType(name);
    }
    return getColorForType(fromCache!);
  }
}
