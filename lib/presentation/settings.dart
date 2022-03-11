import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? prefs;

  _SettingsPageState() {
    _loadSettings();
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Content Rating'),
          Divider(),
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
          Divider(),
        ],
      ),
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
