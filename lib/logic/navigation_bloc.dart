import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/board_delegator.dart';
import 'package:shinoni/data/db/db.dart';
import 'package:shinoni/util.dart';

import '../data/api/booru.dart';

part 'navigation_event.dart';

part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final SharedPreferences prefs;
  final DB db;
  final BoardDelegator boardDelegator;

  NavigationBloc(this.prefs, this.db, this.boardDelegator)
      : super(NavigationInitial()) {
    on<NavigationEvent>((event, emit) async {
      var handled = await _handleSettingsEvents(event, emit);
      if (!handled) {
        handled = await _handlePostEvents(event, emit);
      }
      if (handled) {
        return;
      }
      if (event is OpenHome) {
        boardDelegator.homeIndex = prefs.homeBoardIndex;
        boardDelegator.isInHome = true;
        emit(Loading('Loading Posts', 0));
        emit(await _loadFistPage(isHome: true));
      } else if (event is OpenPosts) {
        boardDelegator.isInHome = false;
        emit(Loading('Loading Posts', 0));
        emit(await _loadFistPage());
      } else if (event is OpenSearch) {
        emit(SearchState(boardDelegator.boardUrl));
      } else if (event is SearchEvent) {
        NavigationState? lastState;
        if (state is PostDetailsState) {
          lastState = state;
        }
        emit(await _loadFistPage(tag: event.tag, prevState: lastState));
      } else if (event is GoBackEvent) {
        if ((state as CanGoBack).lastState != null) {
          emit((state as CanGoBack).lastState!);
        }
      }
    });
  }

  Future<PostPageLoaded> _loadFistPage({
    bool isHome = false,
    String tag = '',
    NavigationState? prevState,
    double scrollOffset = 0,
  }) async {
    SelfPopulatingList<Post> list = SelfPopulatingList(
      await boardDelegator.requestFirstPage(tag: tag),
      () => boardDelegator.requestNextPage(tag: tag),
      3,
    );
    return PostPageLoaded(isHome, '${boardDelegator.boardUrl} $tag', list, prevState,
        scrollOffset: scrollOffset);
  }

  Future<bool> _handlePostEvents(
    NavigationEvent event,
    Emitter<NavigationState> emit,
  ) async {
    if (event is OpenPostDetails) {
      final cState = state as PostPageLoaded;
      cState.scrollOffset = event.scrollOffset;
      emit(PostDetailsState(
        state.title,
        cState.postList,
        event.postIndex,
        state,
        boardDelegator.canSave,
        boardDelegator.canDelete,
      ));
      return true;
    }
    return false;
  }

  Future<bool> _handleSettingsEvents(
    NavigationEvent event,
    Emitter<NavigationState> emit,
  ) async {
    if (event is OpenSettings) {
      emit(SettingsState(db.getBoardList(), prefs.homeBoardIndex));
      return true;
    } else if (event is AddBoardEvent) {
      db.addBoard(
          BoardData(event.type, event.url, login: event.login, pw: event.pw));
      emit(SettingsState(db.getBoardList(), prefs.homeBoardIndex));
    } else if (event is SelectBoardEvent) {
      emit(Loading('Loading Posts', 0));
      boardDelegator.select(event.boardUrl);
      prefs.setString('selectedBoard', event.boardUrl);
      emit(await _loadFistPage());
      return true;
    } else if (event is SetHomeBoardEvent) {
      final idx = boardDelegator.indexOfBoard(event.boardUrl);
      prefs.homeBoardIndex = idx;
      boardDelegator.homeIndex = idx;
      boardDelegator.isInHome = true;
      add(OpenHome());
      return true;
    } else if (event is RemoveBoardEvent) {
      await db.removeBoard(event.boardUrl);
      emit(SettingsState(db.getBoardList(), prefs.homeBoardIndex));
      return true;
    }
    return false;
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

  void removeAt(int index) {
    baseList.removeAt(index);
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
