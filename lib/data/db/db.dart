import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shinoni/data/api/booru.dart';

import '../../util.dart';

part 'db.g.dart';

@HiveType(typeId: 0)
class BoardData {
  @HiveField(0)
  final APIType type;
  @HiveField(1)
  final String baseUrl;
  @HiveField(2)
  final String? login;
  @HiveField(3)
  final String? pw;

  BoardData(this.type, this.baseUrl, {this.login, this.pw});
}

@HiveType(typeId: 1)
enum APIType {
  @HiveField(0)
  moebooru,
  @HiveField(1)
  szurubooru
}

class DB {
  late Box<int> _tagTypesBox;
  late Box<String> _favTagBox;
  late Box<BoardData> _boardDataBox;

  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String hiveDir = '${appDocDir.path}/hive';
    logD('hive dir $hiveDir');
    Hive.init(hiveDir);
    Hive.registerAdapter(BoardDataAdapter());
    Hive.registerAdapter(APITypeAdapter());
    _tagTypesBox = await Hive.openBox<int>('tagTypes');
    _favTagBox = await Hive.openBox<String>('favTags');
    _boardDataBox = await Hive.openBox<BoardData>('boardData');
  }

  void storeTagType(Tag tag) {
    logD('store tag type "${tag.name}"');
    _tagTypesBox.put(tag.name, tag.type);
  }

  int? getTagType(String name) {
    return _tagTypesBox.get(name);
  }

  void favTag(String name) {
    _favTagBox.put(name, name);
  }

  void unFavTag(String name) {
    _favTagBox.delete(name);
  }

  bool isFavTag(String name) {
    return _favTagBox.containsKey(name);
  }

  List<String> getAllFavTags() {
    return _favTagBox.values.toList();
  }

  List<BoardData> getBoardList() {
    return _boardDataBox.values.toList();
  }

  void addBoard(BoardData boardData) {
    _boardDataBox.add(boardData);
  }

  void removeBoard(String boardUrl) {
    final board = _boardDataBox.values
        .firstWhere((element) => element.baseUrl == boardUrl);
    _boardDataBox.delete(board);
  }
}
