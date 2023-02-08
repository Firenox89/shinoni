import 'package:flutter/material.dart';
import 'package:shinoni/logic/post_bloc.dart';

import '../data/api/booru.dart';
import '../logic/navigation_bloc.dart';
import '../util.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class PostDetailsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.network(
            postList.getSync(startIndex).sampleUrl,
            fit: BoxFit.fitWidth,
            frameBuilder: (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (frame == null) {
                return Image.network(
                  postList.getSync(startIndex).previewUrl,
                  fit: BoxFit.fitWidth,
                  width: postList.getSync(startIndex).sampleWidth.toDouble(),
                  height: postList.getSync(startIndex).sampleHeight.toDouble(),
                );
              } else {
                return child;
              }
            },
          ),
          !canDelete && canSave ? _buildDownloadView(context) : Container(),
          canDelete ? _buildDeleteView(context) : Container(),
          _buildTagView(context),
        ],
      ),
    );
  }

  Widget _buildDownloadView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  context.dataBloc
                      .add(SavePostEvent(postList.getSync(startIndex)));
                },
                child: Text('Download')),
          ),
          Text('FileSize: ' +
              (postList.getSync(startIndex).fileSize / (1024 * 1024))
                  .toStringAsFixed(2) +
              ' MB'),
          Text(
              'Size: ${postList.getSync(startIndex).width}x${postList.getSync(startIndex).height}'),
        ],
      ),
    );
  }

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
                    context.dataBloc
                        .add(DeletePostEvent(postList.getSync(startIndex)));
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
    final left = postList
        .getSync(startIndex)
        .tags
        .sublist(0, postList.getSync(startIndex).tags.length ~/ 2);
    final right = postList
        .getSync(startIndex)
        .tags
        .sublist(postList.getSync(startIndex).tags.length ~/ 2);

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
  Color? color;
  bool isFav = false;

  _TagLabelState(this.tag) {
    _loadData();
  }

  void _loadData() async {
    color = await tag.color;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = color != null ? color! : Colors.white;

    isFav = context.db.isFavTag(tag.name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.mainBloc.add(SearchEvent(tag.name));
            },
            child: Text(tag.name,
                style: TextStyle(color: textColor, fontSize: 20)),
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
