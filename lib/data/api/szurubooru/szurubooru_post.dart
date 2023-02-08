import 'package:shinoni/data/api/szurubooru/szurubooru_tag.dart';

import '../booru.dart';

class SzurubooruPost extends Post {
  final String board;
  late List<Tag> tags;
  late String fileUrl;
  late String previewUrl;
  late String rating;
  late String sampleUrl;
  late String source;
  late int fileSize;
  late int height;
  late int id;
  late int previewHeight;
  late int previewWidth;
  late int sampleHeight;
  late int sampleWidth;
  late int width;
  late int version;

  SzurubooruPost.fromJson(this.board, Map<String, dynamic> json)
      : id = json['id'] as int,
        source = json['source'] as String,
        tags = (json['tags'] as List<dynamic>)
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
        width = json['canvasWidth'] as int,
        version = json['version'] as int;
}
