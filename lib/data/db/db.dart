import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../util.dart';
import '../model/tag.dart';

class DB {
  late Box<int> _tagTypesBox;
  late Box<String> _favTagBox;

  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String hiveDir = '${appDocDir.path}/hive';
    logD('hive dir $hiveDir');
    Hive.init(hiveDir);
    _tagTypesBox = await Hive.openBox<int>('tagTypes');
    _favTagBox = await Hive.openBox<String>('favTags');
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
}
