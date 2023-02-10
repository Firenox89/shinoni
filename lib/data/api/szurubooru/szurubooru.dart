import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/booru.dart';
import 'package:shinoni/data/api/szurubooru/szurubooru_post.dart';

import '../../../util.dart';
import '../../db/db.dart';

const limit = 20;

class Szurubooru extends Booru {
  @override
  final String boardUrl;
  final String? login;
  final String? pw;
  final DB db;
  late Dio dio;
  SharedPreferences prefs;

  @override
  bool get hasLogin => login != null;

  var currentPage = 0;

  Szurubooru(this.boardUrl, this.login, this.pw, this.prefs, this.db) {
    dio = Dio(BaseOptions(
      baseUrl: boardUrl,
      headers: <String, String>{
        'Authorization': 'Basic ' + base64.encode(utf8.encode('$login:$pw')),
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

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
    final request = '/api/posts?limit=$limit' +
        ((page > 1) ? '&offset=${page * limit}' : '') +
        ((tags != '') ? '&query=$tags' : '');

    logD(request);

    var res = await _getRequest(request);
    var posts = ((res.data as Map<String, dynamic>)['results'] as List<dynamic>)
        .map((dynamic x) =>
            SzurubooruPost.fromJson(boardUrl, x as Map<String, dynamic>))
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
    throw UnimplementedError();
  }

  @override
  Future<void> savePost(Post post) {
    return _createPost(
      post.fileUrl,
      post.tags,
      post.rating,
      post.source,
      post.board,
      post.id,
    );
  }

  @override
  Future<void> deletePost(Post post) async {
    final szuruPost = post as SzurubooruPost;

    final data = <String, dynamic>{'version': szuruPost.version};
    final path = '/api/post/' + post.id.toString();
    logD('Delete ' + post.toString());
    await dio.delete<void>(path, data: data);
  }

  Future<Response<Map<String, dynamic>>> _getRequest(String request) async {
    try {
      return dio.get<Map<String, dynamic>>(request);
    } on DioError catch (dioError) {
      logE(dioError.response.toString());
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> _postRequest(
    String path,
    dynamic data,
  ) async {
    try {
      logD('Create ' + path + ' data ' + data.toString());
      return await dio.post<Map<String, dynamic>>(path, data: data);
    } on DioError catch (dioError) {
      if (dioError.type == DioErrorType.response) {
        logD('req ' + path + ' data: ' + data.toString());
        logD('rsp ' + dioError.response.toString());
      }
      rethrow;
    }
  }

  Future<void> _createTag(String name, int category) async =>
      _postRequest('/api/tags', <String, dynamic>{
        'names': [name],
        'category': category
      });

  Future<bool> _hasTag(String name) async {
    var res = await _getRequest('/api/tags?query=name:$name');
    var data = res.data as Map<String, dynamic>;
    return (data['total'] as int) > 0;
  }

  Future<void> _createPost(
    String fileUrl,
    List<Tag> tags,
    String rating,
    String? source,
    String board,
    int boardId,
  ) async {
    var szuruRating = 'unsafe';
    if (rating == 's') {
      szuruRating = 'safe';
    } else if (rating == 'q') {
      szuruRating = 'sketchy';
    }
    for (final tag in tags) {
      if (!await _hasTag(tag.name)) {
        await _createTag(tag.name, await tag.type);
      }
    }
    final boardName = (board.replaceAll(RegExp('https?://'), '').replaceAll('/', ''));
    final originTag = '${boardName}_$boardId';
    final tagList = tags.map((e) => e.name).toList()..add(originTag);
    final data = <String, dynamic>{
      'tags': tagList,
      'contentUrl': fileUrl,
      'safety': szuruRating,
      'source': source
    };

    await _postRequest('/api/posts', data);
  }
}
