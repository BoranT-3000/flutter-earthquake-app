import 'dart:async';
import "dart:ui";
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'app_bar_search.dart';
import 'drawer/contact.dart';
import 'package:deprem_flutter/search_page.dart';
import 'package:deprem_flutter/drawer/home.dart';
import 'drawer/settings.dart';
import 'news.dart';
import 'splash.dart';
import 'world.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildShrineTheme(),
      title: 'QUAKES',
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (_currentIndex) {
      case 0:
        child = EarthRoute();
        break;
      case 1:
        child = SearchRoute();
        break;
      case 2:
        child = PlacesRoute();
        break;
      case 3:
        child = NewsRoute();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QUAKES',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade500,
        centerTitle: true,
        actions: [
          // Navigate to the Search Screen
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SearchPage())),
              icon: Icon(Icons.search))
        ],
      ),
      bottomNavigationBar: _bottomTab(),
      body: SizedBox.expand(child: child),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '\t  QUAKE APP',
                style: textTheme.headline6,
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('Contact'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectDestination(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _bottomTab() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) => setState(() => _currentIndex = index),
      backgroundColor: Color.fromARGB(255, 231, 167, 73),
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.brightness_1_outlined), label: "Earth"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(
            icon: Icon(Icons.brightness_4_outlined), label: "Places"),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
      ],
    );
  }
}

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _shrineColorScheme,
    textTheme: _buildShrineTextTheme(base.textTheme),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base
      .copyWith(
        caption: base.caption?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
        button: base.button?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: defaultLetterSpacing,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: shrineBrown900,
        bodyColor: shrineBrown900,
      );
}

const ColorScheme _shrineColorScheme = ColorScheme(
  primary: shrinePink100,
  secondary: shrinePink50,
  surface: shrineSurfaceWhite,
  background: shrineBackgroundWhite,
  error: shrineErrorRed,
  onPrimary: shrineBrown900,
  onSecondary: shrineBrown900,
  onSurface: shrineBrown900,
  onBackground: shrineBrown900,
  onError: shrineSurfaceWhite,
  brightness: Brightness.light,
);

// Search Page

const Color shrinePink50 = Color.fromARGB(255, 0, 0, 0);
const Color shrinePink100 =
    Color.fromARGB(255, 40, 100, 127); //Color.fromARGB(255, 3, 55, 79);
const Color shrinePink300 = Color.fromARGB(255, 0, 0, 0);
const Color shrinePink400 = Color.fromARGB(255, 0, 0, 0);
const Color shrineBrown900 = Color(0xFF442B2D);
const Color shrineBrown600 = Color(0xFF7D4F52);
const Color shrineErrorRed = Color(0xFFC5032B);
const Color shrineSurfaceWhite = Color.fromARGB(255, 0, 0, 0);
const Color shrineBackgroundWhite = Color.fromARGB(255, 0, 0, 0);
const defaultLetterSpacing = 0.03;

// türkiye kısmının olduğu yer !!
class PlacesRoute extends StatefulWidget {
  const PlacesRoute({super.key});

  @override
  State<PlacesRoute> createState() => _PlacesRouteState();
}

class _PlacesRouteState extends State<PlacesRoute> {
  final String deprem_url = "https://api.orhanaydogdu.com.tr/deprem/live.php";

  List data = [];

  @override
  void initState() {
    super.initState();
    this.getJsonData();
    // this.get_all_earth_JSON();
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
      onPressed: (function()),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Colors.deepOrange,
      child: Icon(
        icon,
        size: 36.0,
      ),
    );
  }

  Future<String> getJsonData() async {
    var response = await http.get(
        //Encode the url
        Uri.parse(deprem_url),
        //Only accept json response
        headers: {"Accept": "application/json"});

    setState(() {
      var convertDataToJson = jsonDecode(response.body);
      data = convertDataToJson['result'];
    });

    return "Success";
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  '${data[index]['lokasyon']}',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${data[index]['mag']}\n${data[index]['date']}',
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 20.0,
                      fontStyle: FontStyle.italic),
                ),
                leading: Icon(Icons.show_chart),
                contentPadding: EdgeInsets.all(20.0),
                onTap: () {
                  var deger = data[index]['lng'];
                  var deger2 = data[index]['lat'];

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Stack(
                          children: <Widget>[
                            _googlemap(context, deger2, deger),
                          ],
                        );
                      });
                },
              );
            }),
      ),
    );
  }

  Widget _googlemap(BuildContext context, koordinat1, koordinat2) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: LatLng(koordinat1, koordinat2), zoom: 10),
        onMapCreated: (GoogleMapController controller) {
          //_controller.complete(controller);
        },
      ),
    );
  }
}
