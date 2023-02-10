import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shinoni/presentation/post_details_page.dart';
import 'package:shinoni/presentation/tag_text.dart';

import '../data/api/booru.dart';
import '../logic/navigation_bloc.dart';
import '../util.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) => Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  autofocus: true,
                  style: DefaultTextStyle.of(context)
                      .style
                      .copyWith(fontStyle: FontStyle.italic),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                suggestionsCallback: (pattern) async {
                  return await context.boardDelegator.requestTags(pattern);
                },
                itemBuilder: (context, suggestion) {
                  Tag tag = suggestion as Tag;
                  return ListTile(
                    title: GestureDetector(
                      onPanDown: (_) {
                        logD('selected ' + suggestion.toString());
                        context.mainBloc.add(SearchEvent(tag.name));
                      },
                      child: ListTile(title: TagText(tag)),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Fav Tags',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ...context.db.getAllFavTags().map(
                  (e) => TagLabel(OfflineTag(e, 0)),
                )
          ],
        ),
      );
}
