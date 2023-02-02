import 'package:shinoni/data/api/szurubooru/szurubooru_tag.dart';

import '../booru.dart';

class SzurubooruPost extends Post {
  final String board;
  late int id;
  late List<SzurubooruTag> szuruTags;
  late int fileSize;
  late String fileUrl;
  late String previewUrl;
  late int previewWidth;
  late int previewHeight;
  late String sampleUrl;
  late int sampleWidth;
  late int sampleHeight;
  late String rating;
  late int width;
  late int height;

  List<String> get tags => szuruTags.map((e) => e.name).toList();

  SzurubooruPost.fromJson(this.board, Map<String, dynamic> json)
      : id = json['id'] as int,
        szuruTags = (json['tags'] as List<dynamic>)
            .map((dynamic e) =>
                SzurubooruTag.fromJson(board, e as Map<String, dynamic>))
            .toList(),
        fileSize = json['fileSize'] as int,
        fileUrl = board + (json['contentUrl'] as String),
        previewUrl = board + (json['thumbnailUrl'] as String),
        previewWidth = json['canvasWidth'] as int,
        previewHeight = json['canvasHeight'] as int,
        sampleUrl = board + (json['contentUrl'] as String),
        sampleWidth = json['canvasWidth'] as int,
        sampleHeight = json['canvasHeight'] as int,
        rating = json['safety'] as String,
        height = json['canvasHeight'] as int,
        width = json['canvasWidth'] as int;
}
