import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/board_delegator.dart';
import 'package:shinoni/logic/navigation_bloc.dart';
import 'package:shinoni/logic/post_bloc.dart';
import 'package:shinoni/presentation/app_scaffold.dart';
import 'package:shinoni/presentation/post_details_pager.dart';
import 'package:shinoni/presentation/search_page.dart';
import 'package:shinoni/presentation/settings.dart';
import 'package:shinoni/util.dart';
import 'package:yaru/yaru.dart' as yaru;

import 'data/db/db.dart';
import 'presentation/post_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final db = DB();
  await db.init();

  if (db.getBoardList().isEmpty) {
    db.addBoard(BoardData(APIType.moebooru, 'https://yande.re'));
    db.addBoard(BoardData(APIType.moebooru, 'https://konachan.com'));
    prefs.setString('selectedBoard', 'https://yande.re');
  }

  final boardDelegator = BoardDelegator(prefs, db);

  final navBloc = NavigationBloc(prefs, db, boardDelegator);
  final dataBloc = PostBloc(boardDelegator);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: boardDelegator),
        RepositoryProvider.value(value: db)
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => navBloc..add(OpenPosts()),
          ),
          BlocProvider(
            create: (_) => dataBloc,
          ),
        ],
        child: MyApp(navBloc),
      ),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  final NavigationBloc navBloc;

  const MyApp(this.navBloc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      title: 'Shinobooni',
      theme: yaru.darkTheme,
      home: NavWidget(),
    );
  }
}

class NavWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        child: BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is DownloadSucceededState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Download finished.'),
            ),
          );
        } else if (state is DownloadFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Download failed.'),
            ),
          );
        } else if (state is DeleteSucceededState) {
          context.mainBloc.add(GoBackEvent());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Deleted.'),
            ),
          );
        } else if (state is DeleteFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Deletion failed.'),
            ),
          );
        }
      },
      child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) => WillPopScope(
                child: _buildBody(context, state),
                onWillPop: () async {
                  context.mainBloc.add(GoBackEvent());
                  return false;
                },
              )),
    ));
  }

  Widget _buildBody(BuildContext context, NavigationState state) {
    if (state is Loading) {
      return const Center(
        child: Text('Loading'),
      );
    } else if (state is PostPageLoaded) {
      return PostPage(state);
    } else if (state is PostDetailsState) {
      return PostDetailsPager(
        state.postList,
        state.initialIndex,
        state.canSave,
        state.canDelete,
      );
    } else if (state is SearchState) {
      return SearchPage();
    } else if (state is SettingsState) {
      return SettingsPage();
    }
    return const Center(
      child: Text('Huh?'),
    );
  }
}
