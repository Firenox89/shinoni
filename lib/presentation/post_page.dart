import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../data/model/post.dart';
import '../logic/navigation_bloc.dart';
import '../util.dart';

class PostPage extends StatelessWidget {
  final PostPageLoaded state;

  const PostPage(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = ScrollController();
    Timer(Duration(milliseconds: 50),
        () => controller.jumpTo(state.scrollOffset));
    double scrollPosGetter() => controller.offset;

    return MasonryGridView.count(
      crossAxisCount: state.columnCount,
      controller: controller,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      restorationId: 'testId',
      itemBuilder: (context, index) {
        if (index < state.postList.length) {
          final data = state.postList.getSync(index);
          return _buildPostImage(context, data, index, scrollPosGetter);
        }
        return AsyncImageWidget(
            index, () => state.postList.get(index), scrollPosGetter);
      },
    );
  }
}

class AsyncImageWidget extends StatefulWidget {
  final Function onLoad;
  final int index;
  final double Function() scrollPosGetter;

  const AsyncImageWidget(
    this.index,
    this.onLoad,
    this.scrollPosGetter, {
    Key? key,
  }) : super(key: key);

  @override
  _AsyncImageWidgetState createState() => _AsyncImageWidgetState(
        index,
        scrollPosGetter,
        onLoad,
      );
}

class _AsyncImageWidgetState extends State<AsyncImageWidget> {
  final int index;
  final double Function() scrollPosGetter;

  _AsyncImageWidgetState(this.index, this.scrollPosGetter, Function onLoad) {
    load(onLoad);
  }

  static const double placeholderHeight = 500;
  PostModel? data;

  void load(Function onLoad) async {
    data = (await onLoad()) as PostModel?;
    if (data == null) {
      logD('post loading failed');
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return _buildPostImage(context, data!, index, scrollPosGetter);
    }
    return Container(
      height: placeholderHeight,
      color: Colors.white,
    );
  }
}

Widget _buildPostImage(
  BuildContext context,
  PostModel data,
  int index,
  double Function() scrollPosGetter,
) =>
    GestureDetector(
      onTap: () {
        logD('open ${data.id}');
        context.mainBloc.add(OpenPostDetails(index, scrollPosGetter()));
      },
      child: Image.network(
        data.previewUrl,
        fit: BoxFit.fitWidth,
        frameBuilder: (BuildContext context, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
          if (frame == null) {
            return AspectRatio(
              aspectRatio:
                  data.previewWidth.toDouble() / data.previewHeight.toDouble(),
              child: Container(
                color: Colors.white,
              ),
            );
          } else {
            return child;
          }
        },
      ),
    );
