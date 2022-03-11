import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinoni/data/api/moebooru.dart';
import 'package:shinoni/logic/navigation_bloc.dart';
import 'package:shinoni/presentation/app_scaffold.dart';
import 'package:shinoni/presentation/post_details_page.dart';
import 'package:shinoni/presentation/search_page.dart';
import 'package:shinoni/presentation/settings.dart';
import 'package:yaru/yaru.dart' as yaru;

import 'data/db/db.dart';
import 'presentation/post_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final db = DB();
  await db.init();
  final yandere = Moebooru('https://yande.re', prefs, db);
  final navBloc = NavigationBloc(prefs, db, yandere);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: yandere),
        RepositoryProvider.value(value: db)
      ],
      child: BlocProvider(
        create: (_) => navBloc..add(OpenPosts()),
        child: MyApp(navBloc),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NavigationBloc navBloc;

  const MyApp(this.navBloc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) => _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NavigationState state) {
    if (state is Loading) {
      return const Center(
        child: Text('Loading'),
      );
    } else if (state is PostPageLoaded) {
      return PostPage(state);
    } else if (state is PostDetailsState) {
      return PostDetailsPage(state.postList, state.initialIndex);
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
