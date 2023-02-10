import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/booru.dart';
import 'package:shinoni/data/api/szurubooru/szurubooru.dart';
import 'package:shinoni/util.dart';

import '../db/db.dart';
import 'moebooru/moebooru.dart';

class BoardDelegator extends Booru {
  final SharedPreferences prefs;
  final DB db;
  Map<int, Booru> boards;
  int currentSelectedBoard = 0;
  bool isInHome = true;
  int homeIndex = 0;
  int get boardIndex => isInHome ? homeIndex : currentSelectedBoard;

  @override
  bool get canSave => boards.values.any((element) => element.hasLogin);

  @override
  bool get canDelete => boards[boardIndex]!.hasLogin;

  BoardDelegator(this.prefs, this.db)
      : boards = db
            .getBoardList()
            .map<Booru>((e) {
              if (e.type == APIType.moebooru) {
                return Moebooru(e.baseUrl, prefs, db);
              } else if (e.type == APIType.szurubooru) {
                return Szurubooru(e.baseUrl, e.login, e.pw, prefs, db);
              } else {
                throw Error();
              }
            })
            .toList()
            .asMap() {
    final selectedUrl = prefs.getString('selectedBoard');
    boards.forEach((index, value) {
      if (value.boardUrl == selectedUrl) {
        currentSelectedBoard = index;
      }
    });
  }

  @override
  Future<List<Post>> requestFirstPage({String tag = ''}) {
    logD('request first ' + boards[boardIndex]!.boardUrl);
    return boards[boardIndex]!.requestFirstPage(tag: tag);
  }

  @override
  Future<List<Post>> requestNextPage({String tag = ''}) {
    logD('request next ' + boards[boardIndex]!.boardUrl);
    return boards[boardIndex]!.requestNextPage(tag: tag);
  }

  @override
  Future<List<Post>> requestPage(int page, String tags) {
    return boards[boardIndex]!.requestPage(page, tags);
  }

  @override
  Future<List<Tag>> requestTags(String tag) {
    return boards[boardIndex]!.requestTags(tag);
  }

  void select(String boardUrl) {
    logD('select board $boardUrl');
    boards.forEach((index, value) {
      if (value.boardUrl == boardUrl) {
        currentSelectedBoard = index;
      }
    });
  }

  int indexOfBoard(String boardUrl) {
    for (final e in boards.entries) {
      if (e.value.boardUrl == boardUrl) {
        return e.key;
      }
    }
    throw Exception('board not found ' + boardUrl);
  }

  @override
  String get boardUrl => boards[boardIndex]!.boardUrl;

  @override
  Future<void> savePost(Post post) async =>
      boards.values.firstWhere((element) => element.hasLogin).savePost(post);

  @override
  Future<void> deletePost(Post post) async =>
      boards.values.firstWhere((element) => element.hasLogin).deletePost(post);
}
