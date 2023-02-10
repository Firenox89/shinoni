import 'package:flutter/material.dart';
import 'package:shinoni/logic/post_bloc.dart';
import 'package:shinoni/presentation/tag_text.dart';

import '../data/api/booru.dart';
import '../logic/navigation_bloc.dart';
import '../util.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class PostDetailsPage extends StatefulWidget {
  final SelfPopulatingList<Post> postList;
  final int startIndex;

  final bool canSave;
  final bool canDelete;

  const PostDetailsPage(
    this.postList,
    this.startIndex,
    this.canSave,
    this.canDelete, {
    Key? key,
  }) : super(key: key);

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState(
        postList,
        startIndex,
        canSave,
        canDelete,
      );
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final SelfPopulatingList<Post> postList;
  final int startIndex;

  final bool canSave;
  final bool canDelete;

  Post? post;

  _PostDetailsPageState(
    this.postList,
    this.startIndex,
    this.canSave,
    this.canDelete,
  ) {
    _loadPost();
  }

  Future<void> _loadPost() async {
    post = await postList.get(startIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: post == null
          ? Container()
          : Column(
              children: [
                Image.network(
                  post!.sampleUrl,
                  fit: BoxFit.fitWidth,
                  frameBuilder: (
                    BuildContext context,
                    Widget child,
                    int? frame,
                    bool wasSynchronouslyLoaded,
                  ) {
                    if (frame == null) {
                      return Image.network(
                        post!.previewUrl,
                        fit: BoxFit.fitWidth,
                        width: post!.sampleWidth.toDouble(),
                        height: post!.sampleHeight.toDouble(),
                      );
                    } else {
                      return child;
                    }
                  },
                ),
                !canDelete && canSave
                    ? _buildDownloadView(context)
                    : Container(),
                canDelete ? _buildDeleteView(context) : Container(),
                _buildTagView(context),
              ],
            ),
    );
  }

  Widget _buildDownloadView(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    context.dataBloc.add(SavePostEvent(post!));
                  },
                  child: Text('Download')),
            ),
            Text('FileSize: ' +
                (post!.fileSize / (1024 * 1024)).toStringAsFixed(2) +
                ' MB'),
            Text('Size: ${post!.width}x${post!.height}'),
          ],
        ),
      );

  Widget _buildDeleteView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.yellow),
                onPressed: () async {
                  if (await confirm(context,
                      content: Text('Really delete it?'),
                      textOK: Text('Yes'))) {
                    context.dataBloc.add(DeletePostEvent(post!));
                    postList.removeAt(startIndex);
                  }
                },
                child: Text('Delete')),
          ),
        ],
      ),
    );
  }

  Widget _buildTagView(BuildContext context) {
    final left =
        postList.getSync(startIndex).tags.sublist(0, post!.tags.length ~/ 2);
    final right =
        postList.getSync(startIndex).tags.sublist(post!.tags.length ~/ 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: left
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TagLabel(e),
                    ))
                .toList(),
          ),
          Column(
            children: right
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TagLabel(e),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TagLabel extends StatefulWidget {
  final Tag tag;

  const TagLabel(this.tag, {Key? key}) : super(key: key);

  @override
  _TagLabelState createState() => _TagLabelState(tag);
}

class _TagLabelState extends State<TagLabel> {
  final Tag tag;
  bool isFav = false;

  _TagLabelState(this.tag);

  @override
  Widget build(BuildContext context) {
    isFav = context.db.isFavTag(tag.name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            context.mainBloc.add(SearchEvent(tag.name));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TagText(tag, size: 20),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isFav) {
              context.db.unFavTag(tag.name);
            } else {
              context.db.favTag(tag.name);
            }
            setState(() {});
          },
          child: Icon(isFav ? Icons.favorite : Icons.favorite_outline),
        ),
      ],
    );
  }
}
