
class PostModel {
  late int id;
  late List<String> tags;
  int? createdAt;
  int? updatedAt;
  int? creatorId;
  String? author;
  String? source;
  int? score;
  String? md5;
  late int fileSize;
  String? fileExt;
  String? fileUrl;
  bool? isShownInIndex;
  late String previewUrl;
  late int previewWidth;
  late int previewHeight;
  int? actualPreviewWidth;
  int? actualPreviewHeight;
  late String sampleUrl;
  late int sampleWidth;
  late int sampleHeight;
  int? sampleFileSize;
  String? jpegUrl;
  int? jpegWidth;
  int? jpegHeight;
  int? jpegFileSize;
  late String rating;
  bool? hasChildren;
  int? parentId;
  String? status;
  bool? isPending;
  int? width;
  int? height;
  bool? isHeld;
  int? lastNotedAt;
  int? lastCommentedAt;

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    tags = (json['tags'] as String).split(' ');
    createdAt = json['created_at'] as int?;
    updatedAt = json['updated_at'] as int?;
    creatorId = json['creator_id'] as int?;
    author = json['author'] as String?;
    source = json['source'] as String?;
    score = json['score'] as int?;
    md5 = json['md5'] as String?;
    fileSize = json['file_size'] as int;
    fileExt = json['file_ext'] as String?;
    fileUrl = json['file_url'] as String?;
    isShownInIndex = json['is_shown_in_index'] as bool?;
    previewUrl = json['preview_url'] as String;
    previewWidth = json['preview_width'] as int;
    previewHeight = json['preview_height'] as int;
    actualPreviewWidth = json['actual_preview_width'] as int?;
    actualPreviewHeight = json['actual_preview_height'] as int?;
    sampleUrl = json['sample_url'] as String;
    sampleWidth = json['sample_width'] as int;
    sampleHeight = json['sample_height'] as int;
    sampleFileSize = json['sample_file_size'] as int?;
    jpegUrl = json['jpeg_url'] as String?;
    jpegWidth = json['jpeg_width'] as int?;
    jpegHeight = json['jpeg_height'] as int?;
    jpegFileSize = json['jpeg_file_size'] as int?;
    rating = json['rating'] as String;
    hasChildren = json['has_children'] as bool?;
    parentId = json['parent_id'] as int?;
    status = json['status'] as String?;
    isPending = json['is_pending'] as bool?;
    width = json['width'] as int?;
    height = json['height'] as int?;
    isHeld = json['is_held'] as bool?;
    lastNotedAt = json['last_noted_at'] as int?;
    lastCommentedAt = json[' last_commented_at'] as int?;
  }
}
