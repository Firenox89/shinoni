part of 'navigation_bloc.dart';

@immutable
abstract class NavigationEvent {}

abstract class BottomBarNavEvents extends NavigationEvent {}

class OpenPosts extends BottomBarNavEvents {}

class OpenSearch extends BottomBarNavEvents {}

class OpenBoards extends BottomBarNavEvents {}

class OpenSettings extends BottomBarNavEvents {}

class GoBackEvent extends NavigationEvent {}

class SearchEvent extends NavigationEvent {
  final String tag;

  SearchEvent(this.tag);
}

class OpenPostDetails extends NavigationEvent {
  final int postIndex;
  final double scrollOffset;

  OpenPostDetails(this.postIndex, this.scrollOffset);
}
