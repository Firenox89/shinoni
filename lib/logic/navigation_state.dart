part of 'navigation_bloc.dart';

@immutable
abstract class NavigationState {
  abstract final String title;
  abstract final int navBarIndex;
}

abstract class CanGoBack {
  abstract final NavigationState? lastState;
}

@immutable
class NavigationInitial extends NavigationState {
  @override
  final String title = '';

  @override
  final int navBarIndex = 0;
}

@immutable
class Loading extends NavigationState {
  @override
  final String title = 'Loading';
  final String msg;
  @override
  final int navBarIndex;

  Loading(this.msg, this.navBarIndex);
}

@immutable
class PostPageLoaded extends NavigationState implements CanGoBack {
  @override
  final String title;
  @override
  final int navBarIndex = 0;
  @override
  final NavigationState? lastState;

  double scrollOffset;

  final SelfPopulatingList<PostModel> postList;
  final int columnCount = 3;

  PostPageLoaded(this.title, this.postList, this.lastState, {this.scrollOffset = 0});
}

class SearchState extends NavigationState {
  @override
  int get navBarIndex => 1;

  @override
  String get title => 'Search';
}

class SettingsState extends NavigationState {
  @override
  int get navBarIndex => 3;

  @override
  String get title => 'Settings';
}

@immutable
class PostDetailsState extends NavigationState implements CanGoBack {
  @override
  final String title;
  @override
  final int navBarIndex = 0;
  @override
  final NavigationState lastState;

  final int initialIndex;

  final SelfPopulatingList<PostModel> postList;

  PostDetailsState(this.title, this.postList, this.initialIndex, this.lastState);

}

