part of 'navigation_bloc.dart';

@immutable
abstract class NavigationEvent {}

abstract class BottomBarNavEvents extends NavigationEvent {}

class OpenHome extends BottomBarNavEvents {}

class OpenPosts extends BottomBarNavEvents {}

class OpenSearch extends BottomBarNavEvents {}

class OpenSettings extends BottomBarNavEvents {}

class GoBackEvent extends NavigationEvent {}

class SearchEvent extends NavigationEvent {
  final String tag;

  SearchEvent(this.tag);
}

class AddBoardEvent extends NavigationEvent {
  final APIType type;
  final String url;
  final String login;
  final String pw;

  AddBoardEvent(this.type, this.url, this.login, this.pw);
}

class SelectBoardEvent extends NavigationEvent {
  final String boardUrl;

  SelectBoardEvent(this.boardUrl);
}

class SetHomeBoardEvent extends NavigationEvent {
  final String boardUrl;

  SetHomeBoardEvent(this.boardUrl);
}

class RemoveBoardEvent extends NavigationEvent {
  final String boardUrl;

  RemoveBoardEvent(this.boardUrl);
}

class OpenPostDetails extends NavigationEvent {
  final int postIndex;
  final double scrollOffset;

  OpenPostDetails(this.postIndex, this.scrollOffset);
}
