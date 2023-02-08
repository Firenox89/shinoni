import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shinoni/data/api/booru.dart';

import '../data/api/board_delegator.dart';

part 'post_event_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final BoardDelegator boardDelegator;

  PostBloc(this.boardDelegator) : super(PostInitial()) {
    on<PostEvent>((event, emit) async {
      if (event is SavePostEvent) {
        await boardDelegator.savePost(event.post);
        emit(DownloadSucceededState());
      } else if (event is DeletePostEvent) {
        await boardDelegator.deletePost(event.post);
        emit(DeleteSucceededState());
      }
    });
  }
}
