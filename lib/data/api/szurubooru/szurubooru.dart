import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/booru.dart';
import 'package:shinoni/data/api/szurubooru/szurubooru_post.dart';
import 'package:shinoni/data/api/szurubooru/szurubooru_tag.dart';

import '../../../util.dart';
import '../../db/db.dart';

const limit = 20;

class Szurubooru extends Booru {
  final dio = Dio(BaseOptions());
  final String boardUrl;
  final String? login;
  final String? pw;
  final DB db;
  final List<SzurubooruTag> tagCache = [];
  SharedPreferences prefs;

  var currentPage = 0;

  Szurubooru(this.boardUrl, this.login, this.pw, this.prefs, this.db);

  @override
  Future<List<SzurubooruPost>> requestFirstPage({String tag = ''}) {
    logD('Request first page');
    currentPage = 0;
    return requestNextPage(tag: tag);
  }

  @override
  Future<List<SzurubooruPost>> requestNextPage({String tag = ''}) {
    logD('Request next page');
    return requestPage(++currentPage, tag);
  }

  @override
  Future<List<SzurubooruPost>> requestPage(int page, String tags) async {
    final request = '$boardUrl/api/posts?limit=$limit' +
        ((page > 1) ? '&offset=${page * limit}' : '') +
        ((tags != '') ? '&tags=$tags' : '');

    logD(request);
    var res = await dio.get<Map<String, dynamic>>(request,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
    var posts = ((res.data as Map<String, dynamic>)['results'] as List<dynamic>)
        .map((dynamic x) =>
            SzurubooruPost.fromJson(boardUrl, x as Map<String, dynamic>))
        .toList();

    for (final post in posts) {
      for (final tag in post.szuruTags) {
        if (!tagCache.contains(tag)) {
          tagCache.add(tag);
        }
      }
    }

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
    tagCache.firstWhere((element) => element.name == tag);

    final request = '$boardUrl/tag.json?name=$tag&limit=0';

    logD(request);
    var res = await dio.get<List<dynamic>>(request,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));
    var tags = (res.data as List<dynamic>)
        .map((dynamic x) =>
            SzurubooruTag.fromJson(boardUrl, x as Map<String, dynamic>))
        .toList();
    var copy = tags.toList();
    copy.removeWhere((element) => element.name.startsWith(tag));
    tags.removeWhere((element) => !element.name.startsWith(tag));
    return tags + copy;
  }

  @override
  Future<Color> requestTagColor(String name) async {
    return tagCache.firstWhere((element) => element.name == name).color;
  }
}
