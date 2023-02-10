import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shinoni/data/api/booru.dart';
import 'package:shinoni/logic/navigation_bloc.dart';
import 'package:shinoni/presentation/post_details_page.dart';
import 'package:shinoni/util.dart';

class PostDetailsPager extends StatelessWidget {
  final SelfPopulatingList<Post> postList;
  final int initialIndex;
  final bool canSave;
  final bool canDelete;
  late PageController pageController;

  PostDetailsPager(
    this.postList,
    this.initialIndex,
    this.canSave,
    this.canDelete, {
    Key? key,
  }) : super(key: key) {
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final fNode = FocusNode(descendantsAreFocusable: false, descendantsAreTraversable: false, onKey: (node, event) {
      if (event is RawKeyDownEvent &&
          (event.data.logicalKey == LogicalKeyboardKey.arrowRight)) {
        pageController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      } else if (event is RawKeyDownEvent &&
          (event.data.logicalKey == LogicalKeyboardKey.arrowLeft)) {
        pageController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
      logD('fnode event');
      return KeyEventResult.handled;
    });
    return Center(
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return RawKeyboardListener(
            focusNode: fNode,
            autofocus: true,
            child: PostDetailsPage(postList, index, canSave, canDelete),
          );
        },
      ),
    );
  }
}
