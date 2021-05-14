import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Conatianmentzone App'),
      ),
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: MyApp(),
      ),
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool signin = true;

  TextEditingController namectrl, emailctrl, passctrl;

  bool processing = false;

  @override
  void initState() {
    super.initState();
    namectrl = new TextEditingController();
    emailctrl = new TextEditingController();
    passctrl = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 200,
              color: Colors.blue,
            ),
            boxUi(),
          ],
        ));
  }

  void changeState() {
    if (signin) {
      setState(() {
        signin = false;
      });
    } else
      setState(() {
        signin = true;
      });
  }

  void registerUser() async {
    setState(() {
      processing = true;
    });
    var url = "https://containment.000webhostapp.com/signup.php";
    var data = {
      "email": emailctrl.text,
      "name": namectrl.text,
      "pass": passctrl.text,
    };

    var res = await http.post(url, body: data);

    if (jsonDecode(res.body) == "account already exists") {
      Fluttertoast.showToast(
          msg: "account exists, Please login", toastLength: Toast.LENGTH_SHORT);
    } else {
      if (jsonDecode(res.body) == "true") {
        Fluttertoast.showToast(
            msg: "account created", toastLength: Toast.LENGTH_SHORT);
      } else {
        Fluttertoast.showToast(msg: "error", toastLength: Toast.LENGTH_SHORT);
      }
    }
    setState(() {
      processing = false;
    });
  }

  void userSignIn() async {
    setState(() {
      processing = true;
    });
    var url = "https://containment.000webhostapp.com/signin.php";
    var data = {
      "name": namectrl.text,
      "pass": passctrl.text,
    };
    print(namectrl.text.runtimeType);
    var res = await http.post(url, body: data);
    print(data);
    if (jsonDecode(res.body) == "dont have an account") {
      Fluttertoast.showToast(
          msg: "dont have an account,Create an account",
          toastLength: Toast.LENGTH_SHORT);
    } else {
      if (jsonDecode(res.body) == "false") {
        //Fluttertoast.showToast(msg: "login sucessfull!",toastLength: Toast.LENGTH_SHORT);
        Fluttertoast.showToast(
            msg: "Incorrect password", toastLength: Toast.LENGTH_SHORT);
      } else {
        var id = jsonDecode(res.body);
        print(id);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecondRoute(id)),
        );
      }
    }

    setState(() {
      processing = false;
    });
  }

  Widget boxUi() {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  onPressed: () => changeState(),
                  child: Text(
                    'SIGN IN',
                    style: GoogleFonts.varelaRound(
                      color: signin == true ? Colors.blue : Colors.grey,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () => changeState(),
                  child: Text(
                    'SIGN UP',
                    style: GoogleFonts.varelaRound(
                      color: signin != true ? Colors.blue : Colors.grey,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            signin == true ? signInUi() : signUpUi(),
          ],
        ),
      ),
    );
  }

  Widget signInUi() {
    return Column(
      children: <Widget>[
        TextField(
          controller: namectrl,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.account_circle,
              ),
              hintText: 'Name'),
        ),
        TextField(
          controller: passctrl,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock,
              ),
              hintText: 'Password'),
        ),
        SizedBox(
          height: 10.0,
        ),
        MaterialButton(
            onPressed: () => userSignIn(),
            child: processing == false
                ? Text(
                    'Sign In',
                    style: GoogleFonts.varelaRound(
                        fontSize: 18.0, color: Colors.blue),
                  )
                : CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  )),
      ],
    );
  }

  Widget signUpUi() {
    return Column(
      children: <Widget>[
        TextField(
          controller: namectrl,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.account_box,
              ),
              hintText: 'Name'),
        ),
        TextField(
          controller: emailctrl,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email,
              ),
              hintText: 'Email'),
        ),
        TextField(
          controller: passctrl,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock,
              ),
              hintText: 'Password'),
        ),
        SizedBox(
          height: 10.0,
        ),
        MaterialButton(
            onPressed: () => registerUser(),
            child: processing == false
                ? Text(
                    'Sign Up',
                    style: GoogleFonts.varelaRound(
                        fontSize: 18.0, color: Colors.blue),
                  )
                : CircularProgressIndicator(backgroundColor: Colors.red)),
      ],
    );
  }
}

class SecondRoute extends StatefulWidget {
  final String id;
  const SecondRoute(this.id);

  @override
  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  Position _currentPosition;
  String _currentAddress;
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Info"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentPosition != null)
              Text(
                  "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
            if (_currentAddress != null) Text(_currentAddress),
            FlatButton(
              color: Colors.blue,
              child: Text(
                "Get location",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                _getCurrentLocation();
                var b = widget.id; // A string.
                var latitude = "${_currentPosition.latitude}";
                var longitude = "${_currentPosition.longitude}";
                var place = _currentAddress;
                print(b.runtimeType);
                locationinfo(b, latitude, longitude,place);
              },
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }
  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void locationinfo(String id, String latitude, String longitude,String place) async {
    setState(() {
      processing = true;
    });
    //var a = id;
    var url = "https://containment.000webhostapp.com/location.php";
    var data = {
      "id": id,
      "latitude": latitude,
      "longitude": longitude,
      "place": place
    };
    print(data);
    var res = await http.post(url, body: data);
    if (jsonDecode(res.body) == "true") {
      Fluttertoast.showToast(
          msg: "Location Updated", toastLength: Toast.LENGTH_SHORT);
    } else {
      Fluttertoast.showToast(msg: "Error", toastLength: Toast.LENGTH_SHORT);
    }

    setState(() {
      processing = false;
    });
  }
}
