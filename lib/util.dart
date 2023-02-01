import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/board_delegator.dart';
import 'package:shinoni/logic/navigation_bloc.dart';

import 'data/db/db.dart';

extension BuilderContextExt on BuildContext {
  NavigationBloc get mainBloc => BlocProvider.of<NavigationBloc>(this);
  BoardDelegator get boardDelegator => RepositoryProvider.of<BoardDelegator>(this);
  DB get db => RepositoryProvider.of<DB>(this);
}

const keyRatingSafe = 'RatingSafe';
const keyRatingQuestionable = 'RatingQuestionable';
const keyRatingExplicit = 'RatingExplicit';

extension SharedPrefsExt on SharedPreferences {
  bool get inclSafe => getBool(keyRatingSafe) ?? true;
  bool get inclQuestionable => getBool(keyRatingQuestionable) ?? false;
  bool get inclExplicit => getBool(keyRatingExplicit) ?? false;
  set inclSafe (bool value) => setBool(keyRatingSafe, value);
  set inclQuestionable (bool value) => setBool(keyRatingQuestionable, value);
  set inclExplicit (bool value) => setBool(keyRatingExplicit, value);
}

void logD(String msg) {
  stdout.writeln(msg);
}

void logE(String msg) {
  stderr.writeln(msg);
}
