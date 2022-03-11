import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shinoni/presentation/post_details_page.dart';

import '../data/model/tag.dart';
import '../data/api/moebooru.dart';
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
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                autofocus: true,
                style: DefaultTextStyle.of(context)
                    .style
                    .copyWith(fontStyle: FontStyle.italic),
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              suggestionsCallback: (pattern) async {
                return await context.moebooru.requestTags(pattern);
              },
              itemBuilder: (context, suggestion) {
                Tag tag = suggestion as Tag;
                return ListTile(
                  title: Text(
                    tag.name,
                    style: TextStyle(color: tag.color),
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                context.mainBloc.add(SearchEvent((suggestion as Tag).name));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Fav Tags',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ...context.db.getAllFavTags().map(
                  (e) => TagLabel(e, context.moebooru),
                )
          ],
        ),
      );
}
