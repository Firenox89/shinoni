import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinoni/data/db/db.dart';

import '../logic/navigation_bloc.dart';
import '../util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? prefs;
  final boardUrlController = TextEditingController();
  final loginController = TextEditingController();
  final pwController = TextEditingController();
  APIType selectedApiType = APIType.moebooru;

  _SettingsPageState() {
    _loadSettings();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    boardUrlController.dispose();
    super.dispose();
  }

  void _loadSettings() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {});
  }

  void store(String key, String value) async {
    await prefs!.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (prefs == null) {
      return Center(child: Text('Loading Settings'));
    }
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Content Rating'),
            Divider(),
            _buildContentRating(),
            Divider(),
            Text('Boards'),
            Divider(),
            _buildBoardList(context.mainBloc, state as SettingsState),
            Divider(),
            Text('Add Board'),
            Divider(),
            _buildBoardAdder(context.mainBloc)
          ],
        ),
      ),
    );
  }

  Widget _buildBoardList(NavigationBloc bloc, SettingsState state) {
    return Column(
        children: state.boardList
            .asMap()
            .entries
            .map<Widget>(
              (e) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child:
                          Container(width: 300, child: Text(e.value.baseUrl)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton(
                          onPressed: () {
                            bloc.add(SelectBoardEvent(e.value.baseUrl));
                          },
                          child: Text('Select')),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton(
                          onPressed: e.key == state.homeBoardIndex
                              ? null
                              : () {
                                  bloc.add(SetHomeBoardEvent(e.value.baseUrl));
                                },
                          style: e.key == state.homeBoardIndex
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.yellow)
                              : ElevatedButton.styleFrom(),
                          child: Text('Set as Home')),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.yellow),
                          onPressed: () {
                            bloc.add(RemoveBoardEvent(e.value.baseUrl));
                          },
                          child: Text('Remove')),
                    ),
                  ],
                ),
              ),
            )
            .toList());
  }

  Widget _buildBoardAdder(NavigationBloc bloc) {
    return Column(
      children: [
        TextField(
          controller: boardUrlController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'BoardUrl',
          ),
        ),
        TextField(
          controller: loginController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Login',
          ),
        ),
        TextField(
          controller: pwController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'pw',
          ),
        ),
        DropdownButton<APIType>(
          value: selectedApiType,
          items: APIType.values.map((APIType value) {
            return DropdownMenuItem<APIType>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              selectedApiType = value;
              setState(() {});
            }
          },
        ),
        ElevatedButton(
            onPressed: () {
              bloc.add(
                AddBoardEvent(
                  selectedApiType,
                  boardUrlController.text,
                  loginController.text,
                  pwController.text,
                ),
              );
            },
            child: Text('Add')),
      ],
    );
  }

  Widget _buildContentRating() {
    return Column(
      children: [
        _buildCheckboxRow(
          'Safe Content',
          prefs!.inclSafe,
          (value) {
            prefs!.inclSafe = value!;
            setState(() {});
          },
        ),
        _buildCheckboxRow(
          'Questionable Content',
          prefs!.inclQuestionable,
          (value) {
            prefs!.inclQuestionable = value!;
            setState(() {});
          },
        ),
        _buildCheckboxRow(
          'Explicit Content',
          prefs!.inclExplicit,
          (value) {
            prefs!.inclExplicit = value!;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(
    String label,
    bool initValue,
    void Function(bool?) onChange,
  ) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Checkbox(value: initValue, onChanged: onChange)
          ],
        ),
      );
}
