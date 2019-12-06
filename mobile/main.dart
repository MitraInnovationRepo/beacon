import 'dart:async';
import 'dart:convert' show json;
import 'dart:ui';

import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewifi/bloc/dealbloc.dart';
import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';

import 'models/dealdata.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  String _clientMAC;
  GoogleSignInAccount _currentUser;
  String _contactText;
  ConnectivityResult result;
  final Dealbloc dealbloc = new Dealbloc();
  @override
  void initState() {
    // _getMACOfDevice();
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        // _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
      '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  Future<String> _getMACOfDevice() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String isConnet;
    isConnet = await client.connect();
    if (isConnet == "session_connected") {
      print(_clientMAC);
      client.disconnect();
    }
  }

  Stream<String> getMacWhenConnected() async* {}

  Widget _buildBody() {
    if (_currentUser != null) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Center(
                child: Column(
              children: <Widget>[
                Material(
                    child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 75,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.orangeAccent,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, right: 15),
                                  child: Material(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.exit_to_app,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _handleSignOut();
                                        });
                                      },
                                    ),
                                    color: Colors.orangeAccent,
                                  ))
                            ],
                          ),
                        ), // App bar
                        ClipPath(
                          clipper: WaveClipperOne(),
                          child: Container(
                            color: Colors.orangeAccent,
                            height: 120,
                            child: Center(
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.black,
                                child: Text(
                                  "Connect",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  print("pressed");
                                  _connectToInternet();
                                },
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 12,
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.orangeAccent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "Hot deals Near you ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ))
                              ],
                            )),

                        Container(
                            height: MediaQuery.of(context).size.height / 2.6,
                            child: StreamBuilder(
                              stream: dealbloc.dealDataListView,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Dealdata>> snapshot) {
                                if (snapshot.hasError)
                                  return Text('Error: ${snapshot.error}');
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                    return Text('Select lot');
                                  case ConnectionState.waiting:
                                    return Text('Awaiting bids...');
                                  case ConnectionState.active:
                                    return Text('\$${snapshot.data}');
                                  case ConnectionState.done:
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: <Widget>[
                                        _hotDeals(data: snapshot.data[0]),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _hotDeals(data: snapshot.data[1]),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        _hotDeals(data: snapshot.data[2]),
                                      ],
                                    );
                                }
                                return null; // unreachable
                              },
                            )),
                      ],
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width / 10,
                      top: MediaQuery.of(context).size.height / 13,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 35,
                        child: CircleAvatar(
                          radius: 33,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          backgroundImage: NetworkImage(_currentUser.photoUrl),
                        ),
                      ),
                    )
                  ],
                ))
              ],
            ))
          ],
        ),
        bottomNavigationBar: FancyBottomNavigation(
          activeIconColor: Colors.white,
          inactiveIconColor: Colors.orangeAccent,
          circleColor: Colors.orangeAccent,
          tabs: [
            TabData(iconData: Icons.home, title: "Home"),
            TabData(iconData: Icons.favorite, title: "Favorite"),
            TabData(iconData: Icons.loyalty, title: "Loyalty")
          ],
          onTabChangedListener: (position) {
            setState(() {
              print(position);
            });
          },
        ),
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 30, top: 150),
          child: ClipPath(
            clipper: RoundedDiagonalPathClipper(),
            child: Container(
                height: 350,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  color: Colors.orange,
                ),
                child: Center(
                  child: MaterialButton(
                    child: Container(
                      width: 160,
                      child: Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.google),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Sigin in with Google")
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      setState(() {
                        _handleSignIn();
                      });
                    },
                    color: Colors.white,
                  ),
                )),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: _buildBody(),
    );
  }

  Future<void> _connectToInternet() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String result;
    String mac;
    String _email;
    try {
      result = await client.connect();
      if (result == "session_connected") {
        mac = await client.execute(
            """ip neigh show "\${SSH_CONNECTION%% *}" | cut -d " " -f 5""");
        //  await client.execute("");
        Future.delayed(Duration(microseconds: 300));
        print(mac);
        await client.execute('ndsctl auth $mac');
        //return true;
      }
      client.disconnect();
    } on PlatformException catch (e) {
      // return false;
    }
  }

  List<Widget> dealBuilder(List<Dealdata> data) {
    List<Text> temp;
    for (var i = 0; i < 5; i++) {
      print(data);
    }
    return temp;
  }
}

class _hotDeals extends StatelessWidget {
  final Dealdata data;
  const _hotDeals({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 240.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orangeAccent, width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            Positioned(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  child: Container(
                    color: Colors.black.withOpacity(0),
                    child: Image.network(
                      data.photoUrl.toString(),
                      fit: BoxFit.cover,
                      height: 150.0,
                      width: 236.0,
                    ),
                  ),
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                ),
              ),
              bottom: 0,
              top: 0,
            ),
            ClipOval(
              clipper: OvalTopBorderClipper(),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(.9),
                ),
              ),
            ),
            Positioned(
                bottom: 120,
                right: 20,
                child: Chip(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  label: Text(
                    "${data.discount}% off",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
            Positioned(
              left: 10,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data.shopName,
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(
                      data.cat,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 250,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.8),
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(40))),
                  height: 60,
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, left: 6),
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                )),
          ],
        ));
  }
}

/*
FutureBuilder<String>(
                future:
                    _getMAC(), // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('Press button to start.');
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Container(
                                child:
                                    Text("YOU ARE NOT CONNECTED TO FREE WIFI"));
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text('Error: ${snapshot.error}');
                      return  Container(
                              child: Text("YOU ARE CONNECTED TO FREE WIFI"),
                            );
                  }
            
                },
              )

*/