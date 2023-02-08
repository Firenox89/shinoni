part of 'post_bloc.dart';

@immutable
abstract class PostEvent {}

class SavePostEvent extends PostEvent {
  final Post post;

  SavePostEvent(this.post);
}

class DeletePostEvent extends PostEvent {
  final Post post;

  DeletePostEvent(this.post);
}

@immutable
abstract class PostState {}

class PostInitial extends PostState {}

class DownloadSucceededState extends PostState {}

class DownloadFailedState extends PostState {}

class DeleteSucceededState extends PostState {}

class DeleteFailedState extends PostState {}
