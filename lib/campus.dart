import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:gcek/constants.dart';
import 'package:geolocator/geolocator.dart';


//import 'app_form/app_widget.dart';
//import 'package:location/location.dart';



class Campus extends StatelessWidget{
    
  
  @override
  Widget build(BuildContext context) {
    
     return MaterialApp(
        debugShowCheckedModeBanner : false,
         home: Home()
         

      );
  }
}

class Home extends  StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String st="Absent";
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
       double long=0 , lat= 0;
  late StreamSubscription<Position> positionStream;

   @override
  void initState() {
    checkGps();
    super.initState();
  }

  checkGps() async {
      servicestatus = await Geolocator.isLocationServiceEnabled();
      if(servicestatus){
            permission = await Geolocator.checkPermission();
          
            if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                    print('Location permissions are denied');
                }else if(permission == LocationPermission.deniedForever){
                    print("'Location permissions are permanently denied");
                }else{
                   haspermission = true;
                }
            }else{
               haspermission = true;
            }

            if(haspermission){
                setState(() {
                  //refresh the UI
                });

                getLocation();
            }
      }else{
        print("GPS Service is not enabled, turn on GPS location");
      }

      setState(() {
         //refresh the UI
      });
   
  }

  getLocation() async {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toDouble();
      lat = position.latitude.toDouble();
      String st;
      setState(() {
         //refresh UI
      });

      LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, //accuracy of the location data
            distanceFilter: 100, //minimum distance (measured in meters) a 
                                 //device must move horizontally before an update event is generated;
      );

      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
            locationSettings: locationSettings).listen((Position position) {
            print(position.longitude); //Output: 80.24599079
            print(position.latitude); //Output: 29.6593457

            long = position.longitude.toDouble();
            lat = position.latitude.toDouble();
           

            setState(() {
              //refresh UI on update
            });
   
      });
       ispresent(lat, long);
  }
   void ispresent(double lat,double long){
    final double la1= 17.307375,lo1=74.188005,la2=17.307546,lo2=74.180782,
    la3=17.311013,lo3=74.187475,la4=17.310884,lo4=74.181521;
    int c =0;
    bool datataken = false;
    bool present = false;
  // la3 is max  la2 is min
        // lo3 is max  lo2 is min
        if((lat>=la2 && lat<=la3) && (long>=lo2 && long <= lo3))
        {
          print("Present");
   
         st="Present";
        

            present = true;
        }else
        {
           print("Absent");
           st="Absent";
        }

    }
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
         backgroundColor: Color(0xFFF5CEB8),
         appBar: AppBar(
            title: Text("Get GPS Location"),
            backgroundColor: Color.fromARGB(255, 238, 188, 148)
         ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
             child: Column(
                children: [ 

                     Text(servicestatus? "GPS is Enabled": "GPS is disabled.",
                     style:TextStyle(
                      height:3.5,
                      )),
                     Text(haspermission? "GPS is Enabled": "GPS is disabled."),
                     
                     Text("Longitude: $long", style:TextStyle(
                      height:3.5,
                      //backgroundColor: Colors.blue,
                      fontSize: 20)),
                     Text("Latitude: $lat", style: TextStyle(fontSize: 20)),
                
                     Text("Student is : $st",style:TextStyle(
                      height: 8.5,
                     // backgroundColor: Colors.lightBlue,
                      fontSize: 30
                      
                      )),
                
                ]
              )
          )
    );

  } 
}

