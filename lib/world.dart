import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

// Dünya kısmının olduğu yer !!
class EarthRoute extends StatefulWidget {
  const EarthRoute({super.key});
  @override
  State<EarthRoute> createState() => _EarthRouteState();
}

class _EarthRouteState extends State<EarthRoute> {
  final String apiUrl =
      "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson";

  List _features = [];

  @override
  void initState() {
    super.initState();
    this.get_world_json();
  }

  Future<String> get_world_json() async {
    var response = await http.get(
        //Encode the url
        Uri.parse(apiUrl),
        //Only accept json response
        headers: {"Accept": "application/json"});

    setState(() {
      var convertDataToJson = jsonDecode(response.body);
      _features = convertDataToJson['features'];
    });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _features.length,
          padding: const EdgeInsets.all(14.2),
          itemBuilder: (BuildContext context, int position) {
            final index = position ~/ 2;
            var format = new DateFormat.yMMMd("en_US").add_jm();
            var date = format.format(new DateTime.fromMillisecondsSinceEpoch(
                _features[index]['properties']['time']));
            return Column(
              children: <Widget>[
                Divider(
                  height: 10.5,
                ),
                ListTile(
                  title: Text(
                    date.toString(),
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 24.5,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _features[position]['properties']['place'].toString(),
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      _features[position]['properties']['mag'].toString(),
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  trailing: new Column(
                    children: <Widget>[
                      new Container(
                        child: new IconButton(
                          icon: new Icon(Icons.map),
                          onPressed: () {
                            /* Your code */
                            somethingontap(
                                context,
                                _features[position]['properties']['place'] +
                                    "\n" +
                                    _features[position]['properties']['type']);
                          },
                        ),
                        margin: EdgeInsets.only(top: 5.0),
                      )
                    ],
                  ),
                  onTap: () => somethingontap(
                      context, _features[position]['properties']['title']),
                )
              ],
            );
          }),
    );
  }
}

void somethingontap(BuildContext context, String message) {
  var alertbox = new AlertDialog(
    title: Text('Quake', style: TextStyle(fontSize: 14.0)),
    content: Text(message),
    actions: <Widget>[
      new FlatButton(
          onPressed: () => Navigator.pop(context), child: const Text("done"))
    ],
  );
  showDialog(
      context: context,
      builder: (context) {
        return alertbox;
      });
}
