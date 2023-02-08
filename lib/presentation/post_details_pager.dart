import 'package:flutter/widgets.dart';
import 'package:shinoni/data/api/booru.dart';
import 'package:shinoni/logic/navigation_bloc.dart';
import 'package:shinoni/presentation/post_details_page.dart';

class PostDetailsPager extends StatelessWidget {
  final SelfPopulatingList<Post> postList;
  final int initialIndex;
  final bool canSave;
  final bool canDelete;
  late PageController pageController;

  PostDetailsPager(this.postList, this.initialIndex,
      this.canSave, this.canDelete, {Key? key,}) : super(key: key) {
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          return PostDetailsPage(postList, index, canSave, canDelete);
        },
      ),
    );
  }
}
