import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:mylocation/login.dart';
import 'package:url_launcher/url_launcher.dart';
class MyHomePage extends StatefulWidget {
  bool? admin = false;
  MyHomePage({this.admin});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? currPoss;
  Future<Position?> setCurrPos() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((value) {
      currPoss = value;
      return currPoss;
    });
  }

  DateTime end = DateTime(2022, 6, 23, 16, 0, 0, 0, 0);
  void initState() {
    // TODO: implement initState
    super.initState();
    Geolocator.checkPermission().then((permission) {
      print("permission is $permission");
      print(permission.name);
      if (permission.index == 0) {
        print("Permission Denied");
        Geolocator.requestPermission().then((permission) {
          print(permission);
          setCurrPos();
        });
      } else if (permission.index == 2 || permission == 1) {
        print("Permission Granted");
        setCurrPos();
      }
      setCurrPos();
      // print(permission.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(onPressed: (){Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Login(),));}, icon: Icon(Icons.exit_to_app_sharp))
        ],
      ),
      body:Builder(
        builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TimerCountdown(
                  format: CountDownTimerFormat.daysHoursMinutesSeconds,
                  endTime: end,
                  onEnd: () {
                  },
                  timeTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  colonsTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  descriptionTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  spacerWidth: 20,
                  daysDescription: "days",
                  hoursDescription: "hrs",
                  minutesDescription: "min",
                  secondsDescription: "sec",
                ),
                const Text(""),
                widget.admin!
                    // ignore: deprecated_member_use
                    ? RaisedButton(
                        onPressed: () async {
                          Map<String, dynamic> myLocation = {
                            'latitude': currPoss!.latitude,
                            "longitude": currPoss!.longitude
                          };
                          try
                          {
                            await FirebaseFirestore.instance.collection("location").doc("abhishek").set(myLocation);
                            // ignore: deprecated_member_use
                            Scaffold.of(context).showSnackBar(const SnackBar(content: Text("Succesfully added the location")));
                          }catch(e)
                          {
                            Scaffold.of(context).showSnackBar(const SnackBar(content: Text("Failed adding the location")));
                          }
                          print(end);
                          print(currPoss);
                        },
                        child: const Text("Send My Location"),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection("location")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if(snapshot.connectionState ==ConnectionState.waiting)
                            {
                              return  Center(
                                child: Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.1,vertical: MediaQuery.of(context).size.height*0.05),
                                  child: Column(
                                    children: const [
                                      CircularProgressIndicator(
                                        semanticsValue: "Loading....",
                                        color: Colors.blueAccent,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          else
                            {
                              if(snapshot.data!.docs.isNotEmpty)
                                {
                                  return RaisedButton(
                                    onPressed: (){
                                      double latitude, longitude;
                                      latitude =
                                          double.parse(snapshot.data!.docs[0]['latitude'].toString());
                                      longitude =
                                          double.parse(snapshot.data!.docs[0]['longitude'].toString());
                                      MapUtils.openMap(latitude, longitude);
                                      MapsLauncher.launchCoordinates(latitude, longitude);
                                    },
                                    child: const Text("See Abhishek's Location"),
                                  );
                                }
                              else
                                {
                                  return const Text("Location not added",style: TextStyle(color: Colors.black),);
                                }
                            }
                        }),
              ],
            ),
          );
        }
      ),
    );
  }
}
class MapUtils {

  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
    }
  }
}
