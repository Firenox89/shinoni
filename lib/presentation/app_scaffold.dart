import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/navigation_bloc.dart';
import '../util.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({required this.child, Key? key}) : super(key: key);

  void handleNavTab(int index, NavigationBloc mainBloc) {
    switch (index) {
      case 0:
        mainBloc.add(OpenPosts());
        break;
      case 1:
        mainBloc.add(OpenSearch());
        break;
      case 2:
        mainBloc.add(OpenSettings());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: _addBackButton(context, state),
          title: Text(state.title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          iconSize: 30,
          currentIndex: state.navBarIndex,
          onTap: (index) => handleNavTab(index, context.mainBloc),
          items: [
            BottomNavigationBarItem(
              label: 'Posts',
              icon: Icon(Icons.image),
            ),
            BottomNavigationBarItem(
              label: 'Search',
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: 'Settings',
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        body: child,
      ),
    );
  }

  Widget? _addBackButton(BuildContext context, NavigationState state) {
    if (state is CanGoBack && (state as CanGoBack).lastState != null) {
      return BackButton(
        onPressed: () => context.mainBloc.add(GoBackEvent()),
      );
    }
    return null;
  }
}
