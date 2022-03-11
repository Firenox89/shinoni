import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/db/db.dart';

import '../data/model/post.dart';
import '../util.dart';
import '../data/api/moebooru.dart';

part 'navigation_event.dart';

part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final SharedPreferences prefs;
  final DB db;
  final Moebooru yandere;

  NavigationBloc(this.prefs, this.db, this.yandere)
      : super(NavigationInitial()) {
    on<NavigationEvent>((event, emit) async {
      if (event is OpenPosts) {
        emit(Loading('Loading Posts', 0));
        emit(await _loadFistPage());
      } else if (event is OpenSearch) {
        emit(SearchState());
      } else if (event is OpenSettings) {
        emit(SettingsState());
      } else if (event is SearchEvent) {
        NavigationState? lastState;
        if (state is PostDetailsState) {
          lastState = state;
        }
        emit(await _loadFistPage(tag: event.tag, prevState: lastState));
      } else if (event is GoBackEvent) {
        emit((state as CanGoBack).lastState!);
      } else if (event is OpenPostDetails) {
        final cState = state as PostPageLoaded;
        cState.scrollOffset = event.scrollOffset;
        emit(PostDetailsState(state.title, cState.postList, event.postIndex, state));
      }
    });
  }

  Future<PostPageLoaded> _loadFistPage({
    String tag = '',
    NavigationState? prevState,
    double scrollOffset = 0,
  }) async {
    SelfPopulatingList<PostModel> list = SelfPopulatingList(
      await yandere.requestFirstPage(tag: tag),
      () => yandere.requestNextPage(tag: tag),
      3,
    );
    return PostPageLoaded('yande.re $tag', list, prevState, scrollOffset: scrollOffset);
  }
}

class SelfPopulatingList<T> {
  final List<T> baseList;
  final int bufferDistance;
  final Future<List<T>> Function() onLoadNewEntries;

  var loadingComplete = false;
  Future<void>? currentLoadOperation;

  SelfPopulatingList(
    this.baseList,
    this.onLoadNewEntries,
    this.bufferDistance,
  );

  int get length => baseList.length - bufferDistance;

  T getSync(int index) {
    return baseList[index];
  }

  Future<T?> get(int index) async {
    if (loadingComplete) {
      if (index < baseList.length) {
        return baseList[index];
      } else {
        return null;
      }
    }
    if (index + bufferDistance > baseList.length) {
      if (currentLoadOperation != null) {
        await currentLoadOperation;
        return get(index);
      }
      populate();
      return get(index);
    }
    return baseList[index];
  }

  Future<void> populate() async {
    var completer = Completer<void>();
    currentLoadOperation = completer.future;
    var newEntries = await onLoadNewEntries();
    if (newEntries.isNotEmpty) {
      baseList.addAll(newEntries);
    } else {
      loadingComplete = true;
    }
    completer.complete();
    currentLoadOperation = null;
  }
}
