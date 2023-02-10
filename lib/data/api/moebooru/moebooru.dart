import 'package:dio/dio.dart';
import 'package:dio_throttler/dio_throttler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/booru.dart';

import '../../../util.dart';
import '../../db/db.dart';
import 'moebooru_post.dart';
import 'moebooru_tag.dart';

const limit = 20;

class Moebooru extends Booru {
  late Dio dio;
  @override
  final String boardUrl;
  final DB db;
  SharedPreferences prefs;

  var currentPage = 0;

  Moebooru(this.boardUrl, this.prefs, this.db) {
    dio = Dio(BaseOptions(
      baseUrl: boardUrl,
    ));
    dio.interceptors.add(DioThrottler(Duration(milliseconds: 300)));
  }

  @override
  Future<List<MoebooruPost>> requestFirstPage({String tag = ''}) {
    currentPage = 0;
    return requestNextPage(tag: tag);
  }

  @override
  Future<List<MoebooruPost>> requestNextPage({String tag = ''}) {
    return requestPage(++currentPage, tag);
  }

  @override
  Future<List<MoebooruPost>> requestPage(int page, String tags) async {
    final request = '/post.json?limit=$limit' +
        ((page > 1) ? '&page=$page' : '') +
        ((tags != '') ? '&tags=$tags' : '');

    logD(request);
    var res = await dio.get<List<dynamic>>(request);
    var posts = (res.data as List<dynamic>)
        .map((dynamic x) => MoebooruPost.fromJson(boardUrl, (String name) {
              return requestTagType(name);
            }, x as Map<String, dynamic>))
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

  @override
  Future<List<Tag>> requestTags(String tag) async {
    if (tag.length < 3) {
      return [];
    }
    logD('request tag: ' + tag);
    final request = '/tag.json?name=$tag&limit=0';

    var res = await dio.get<List<dynamic>>(request);
    var tags = (res.data as List<dynamic>)
        .map((dynamic x) => MoebooruTag.fromJson(x as Map<String, dynamic>))
        .toList();
    await _cacheTagColors(tags);
    var copy = tags.toList();
    copy.removeWhere((element) => element.name.startsWith(tag));
    tags.removeWhere((element) => !element.name.startsWith(tag));
    return tags + copy;
  }

  Future<void> _cacheTagColors(List<MoebooruTag> tags) async {
    for (final tag in tags) {
      await db.storeTagType(tag);
    }
  }

  Future<int> requestTagType(String name) async {
    var fromCache = db.getTagType(name);
    if (fromCache == null) {
      await requestTags(name);
      fromCache = db.getTagType(name);
    }
    return fromCache!;
  }

  @override
  Future<void> savePost(Post post) {
    // TODO: implement savePost
    throw UnimplementedError();
  }

  @override
  Future<void> deletePost(Post post) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }
}
