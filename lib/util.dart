import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/board_delegator.dart';
import 'package:shinoni/logic/navigation_bloc.dart';
import 'package:shinoni/logic/post_bloc.dart';

import 'data/db/db.dart';

extension BuilderContextExt on BuildContext {
  NavigationBloc get mainBloc => BlocProvider.of<NavigationBloc>(this);
  PostBloc get dataBloc => BlocProvider.of<PostBloc>(this);
  BoardDelegator get boardDelegator => RepositoryProvider.of<BoardDelegator>(this);
  DB get db => RepositoryProvider.of<DB>(this);
}

const keyRatingSafe = 'RatingSafe';
const keyRatingQuestionable = 'RatingQuestionable';
const keyRatingExplicit = 'RatingExplicit';
const keyHomeBoardIndex = 'HomeBoardIndex';

extension SharedPrefsExt on SharedPreferences {
  bool get inclSafe => getBool(keyRatingSafe) ?? true;
  bool get inclQuestionable => getBool(keyRatingQuestionable) ?? false;
  bool get inclExplicit => getBool(keyRatingExplicit) ?? false;
  int get homeBoardIndex => getInt(keyHomeBoardIndex) ?? 0;
  set inclSafe (bool value) => setBool(keyRatingSafe, value);
  set inclQuestionable (bool value) => setBool(keyRatingQuestionable, value);
  set inclExplicit (bool value) => setBool(keyRatingExplicit, value);
  set homeBoardIndex (int value) => setInt(keyHomeBoardIndex, value);
}

void logD(String msg) {
  stdout.writeln(msg);
}

void logE(String msg) {
  stderr.writeln(msg);
}
