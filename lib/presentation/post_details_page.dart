import 'package:flutter/material.dart';
import 'package:shinoni/data/api/moebooru.dart';

import '../data/model/post.dart';
import '../logic/navigation_bloc.dart';
import '../util.dart';

class PostDetailsPage extends StatelessWidget {
  final SelfPopulatingList<PostModel> postList;
  final int startIndex;

  const PostDetailsPage(this.postList, this.startIndex, {Key? key})
      : super(key: key);

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: () {}, child: Text('Download')),
          ),
          _buildDownloadView(context),
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
                      child: TagLabel(e, context.moebooru),
                    ))
                .toList(),
          ),
          Column(
            children: right
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TagLabel(e, context.moebooru),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TagLabel extends StatefulWidget {
  final String name;

  final Moebooru moebooru;

  const TagLabel(this.name, this.moebooru, {Key? key}) : super(key: key);

  @override
  _TagLabelState createState() => _TagLabelState(name, moebooru);
}

class _TagLabelState extends State<TagLabel> {
  final String name;
  final Moebooru moebooru;
  Color? color;
  bool isFav = false;

  _TagLabelState(this.name, this.moebooru) {
    _loadData();
  }

  void _loadData() async {
    color = await moebooru.requestTagColor(name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = color != null ? color! : Colors.white;

    isFav = context.db.isFavTag(name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              context.mainBloc.add(SearchEvent(name));
            },
            child: Text(name, style: TextStyle(color: textColor, fontSize: 20)),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isFav) {
              context.db.unFavTag(name);
            } else {
              context.db.favTag(name);
            }
            setState(() {});
          },
          child: Icon(isFav ? Icons.favorite : Icons.favorite_outline),
        ),
      ],
    );
  }
}
