import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_cab/constance/global.dart';
import 'package:my_cab/helpers&widgets/widgets/customListTIle.dart';
import 'package:my_cab/helpers&widgets/widgets/customText.dart';
import 'package:my_cab/helpers&widgets/widgets/loading.dart';
import 'package:my_cab/services/placeServices.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  final String sessionToken;

  AddressSearch(this.sessionToken);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    PlaceApiProvider _placeApiProvider = PlaceApiProvider(sessionToken);
    final geocoding = GeocodingPlatform.instance;
    
    return FutureBuilder(
        future: _placeApiProvider.fetchSuggestions(query, 'en'),
        builder: (context, snapshot) {
          if (query == '') {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: CustomText(
                text: 'Enter your address',
                size: 15,
                maxLines: 20,
                fontWeight: FontWeight.bold,
              )),
            );
          }
          if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Suggestion suggestion = snapshot.data[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: CustomListTile(
                      color: Colors.white,
                      leading: Icon(Icons.location_pin),
                      title: Text(suggestion.description),
                      subtitle: CustomText(
                        text: suggestion.secondaryText,
                        color: grey[400],
                      ),
                      callback: () {
                        close(context, suggestion);
                      },
                    ),
                  );
                });
          }
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
            return Loading(text: 'Fetching places');
          }
          if (snapshot.hasError) {
            return Center(
              child: CustomText(
                text: snapshot.data.toString(),
                size: 13,
                maxLines: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          }

          return Container();
        });
  }
}
