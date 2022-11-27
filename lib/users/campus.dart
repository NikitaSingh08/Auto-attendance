import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:gcek/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

//import 'app_form/app_widget.dart';
//import 'package:location/location.dart';

class Campus extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;
  late final user = auth.currentUser;
  //late final FirebaseUser user = await auth.currentUser();
  //final FirebaseUser user = await auth.currentUser();
  late final userid = user?.uid;

  //late DatabaseReference reference = database.instance.ref();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final TextEditingController _present = new TextEditingController();
  // final TextEditingController rollno = new TextEditingController();
  // final Storage = new FlutterSecureStorage();
  String? rollno;
  FirebaseAuth auth = FirebaseAuth.instance;
  late final user = auth.currentUser;
  String st = "Absent";
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  double long = 0, lat = 0;
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude);
    print(position.latitude);

    long = position.longitude.toDouble();
    lat = position.latitude.toDouble();
    String st;
    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude);
      print(position.latitude);
      long = position.longitude.toDouble();
      lat = position.latitude.toDouble();

      setState(() {
        //refresh UI on update
      });
    });
    ispresent(lat, long);
  }

  void ispresent(double lat, double long) {
    const double la1 = 17.307375,
        lo1 = 74.188005,
        la2 = 17.307546,
        lo2 = 74.180782,
        la3 = 17.311013,
        lo3 = 74.187475,
        la4 = 17.310884,
        lo4 = 74.181521;
    int c = 0;
    bool datataken = false;
    bool present = false;
    // la3 is max  la2 is min
    // lo3 is max  lo2 is min
    if ((lat >= la2 && lat <= la3) && (long >= lo2 && long <= lo3)) {
      print("Present");

      st = "Present";

      present = true;
    } else {
      print("Absent");
      st = "Absent";
    }

    FirebaseFirestore.instance
        .collection('Attendance')
        .add({
          "timestamp": FieldValue.serverTimestamp(),
          "status": st.toString(),
          "userid": user?.uid.toString(),
          // "rollno": rollno,
        })
        .then((value) => print(""))
        .catchError((error) => print("Failed: $error"));
  }

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
          width: 1.4 * screenWidth,
          height: 1.2 * screenWidth,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
              gradient: const LinearGradient(
                  begin: Alignment(-0.2, -0.8),
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x007CBFCF),
                    Color(0xB316BFC4),
                  ]))),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      //backgroundColor: Color.fromARGB(128, 18, 94, 57),
      // Color(0xFFF5CEB8),
      appBar: AppBar(
          title: Text("Checking Location..."),
          backgroundColor: Color.fromARGB(255, 18, 112, 163)),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -50,
            child: topWidget(screenSize.width),
          ),
          Positioned(
            bottom: -80,
            left: -70,
            child: bottomWidget(screenSize.width),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            child: Column(
              children: [
                Text(servicestatus ? "GPS is Enabled" : "GPS is disabled.",
                    style: TextStyle(
                      height: 3.5,
                    )),
                Text(haspermission ? "" : ""),
                Container(
                  // padding: const EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Text("Longitude: $long",
                      style: TextStyle(height: 3.5, fontSize: 20)),
                  width: 300,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(255, 166, 234, 239),
                      Color.fromARGB(116, 179, 229, 240),
                      // Color.fromARGB(255, 246, 176, 142),
                      // Color.fromARGB(255, 241, 208, 204)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(189, 26, 183, 227),
                        //color: Color.fromARGB(255, 177, 118, 82),
                        offset: Offset(10, 10),
                        blurRadius: 15,
                      )
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),

                Container(
                  // padding: const EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Text("Latitude: $lat",
                      style: TextStyle(height: 3.5, fontSize: 20)),
                  width: 300,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(255, 143, 247, 231),
                      Color.fromARGB(116, 161, 236, 226),
                      // Color.fromARGB(255, 246, 176, 142),
                      // Color.fromARGB(255, 241, 208, 204)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(199, 22, 167, 145),
                        //color: Color.fromARGB(255, 177, 118, 82),
                        offset: Offset(10, 10),
                        blurRadius: 20,
                      )
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                const SizedBox(
                  height: 120,
                ),
                Container(
                  // padding: const EdgeInsets.all(5),
                  padding: EdgeInsets.only(left: 60, top: 0.4, bottom: 10),
                  child: Text("Status: $st",
                      style: TextStyle(height: 3.5, fontSize: 20)),
                  width: 300,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(255, 168, 247, 235),
                      Color.fromARGB(116, 206, 251, 243),
                      // Color.fromARGB(255, 246, 176, 142),
                      // Color.fromARGB(255, 241, 208, 204)
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(130, 4, 195, 182),
                        //color: Color.fromARGB(255, 177, 118, 82),
                        offset: Offset(10, 10),
                        blurRadius: 20,
                      )
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                // Text("Latitude: $lat", style: TextStyle(fontSize: 20)),
                // Text("Student is : $st",
                //     style: TextStyle(
                //         height: 8.5,
                //         // backgroundColor: Colors.lightBlue,
                //         fontSize: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
