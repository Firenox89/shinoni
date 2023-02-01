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
            .asMap();

  @override
  Future<List<Post>> requestFirstPage({String tag = ''}) {
    return boards[currentSelectedBoard]!.requestFirstPage(tag: tag);
  }

  @override
  Future<List<Post>> requestNextPage({String tag = ''}) {
    return boards[currentSelectedBoard]!.requestNextPage(tag: tag);
  }

  @override
  Future<List<Post>> requestPage(int page, String tags) {
    return boards[currentSelectedBoard]!.requestPage(page, tags);
  }

  @override
  Future<Color> requestTagColor(String name) {
    return boards[currentSelectedBoard]!.requestTagColor(name);
  }

  @override
  Future<List<Tag>> requestTags(String tag) {
    return boards[currentSelectedBoard]!.requestTags(tag);
  }

  void select(String boardUrl) {
    logD('select board $boardUrl');
    boards.forEach((index, value) {
      if (value.boardUrl == boardUrl) {
        currentSelectedBoard = index;
      }
    });
  }

  @override
  String get boardUrl => boards[currentSelectedBoard]!.boardUrl;
}
