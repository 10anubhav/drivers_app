import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:drivers_app/methods/map_theme_methods.dart';
import 'package:drivers_app/pushNotification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/global_var.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{

  final Completer<GoogleMapController> googleMapCompleterController =  Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap ;
  Position? currentPositionOfDriver;
  Color colorToShow=Colors.green;
  String titleToShow ="GO ONLINE NOW";
  bool isDriverAvaliable= false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();



  getCurrentLiveLocationOfDriver() async
  {
    Position positionOfUser = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver= positionOfUser;
    driverCurrentPosition = currentPositionOfDriver;

    LatLng positionOfUserInLatlng= LatLng(currentPositionOfDriver!.latitude,currentPositionOfDriver!.longitude);

    CameraPosition cameraPosition=CameraPosition(target: positionOfUserInLatlng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow()
  {
    //all drivers available for new trip request
      Geofire.initialize("onlineDrivers");

      Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
      );

      newTripRequestReference=FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("newTripStatus:");
      newTripRequestReference!.set("waiting");

      newTripRequestReference!.onValue.listen((event) { });
  }

  setAndGetLocationUpdates()
  {
    positionStreamHomePage=Geolocator.getPositionStream()
        .listen((Position position)
    {
     currentPositionOfDriver = position;

     if(isDriverAvaliable == true)
       {
         Geofire.setLocation(
             FirebaseAuth.instance.currentUser!.uid,
             currentPositionOfDriver!.latitude,
             currentPositionOfDriver!.longitude,
         );
       }


      LatLng positionLatLng = LatLng(position.latitude, position.longitude,);
     controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }


  goOfflineNow()
  {
    //stop sharing update
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //stop listening to the new trip status
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem()
  {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializePushNotificationSystem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: const EdgeInsets.only(top: 136),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);

              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLiveLocationOfDriver();
            },
          ),


          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black87,
          ),
          //go online button
          Positioned(
            top: 61,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        isDismissible: false,
                        builder: (BuildContext contex)
                        {
                          return Container(
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              boxShadow:
                                [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5.0,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.7, 0.7),
                                  ),
                                ],
                            ),
                            height: 221,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: Column(
                              children: [

                                const SizedBox(height: 11,),

                                Text(
                                    (!isDriverAvaliable)? "GO ONLINE NOW" :"GO OFFLINE NOW",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 21,),

                            Text(
                              (!isDriverAvaliable)
                                  ? "You are about to go online, you will be available to receive trip requests from user. "
                                  :"You are about to go offline, you will stop receiving new trip requests from users.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white30,
                              ),
                            ),

                                const SizedBox(height: 25,),


                                Row(
                                  children: [

                                    Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "BACK"
                                          ),
                                        )
                                    ),

                                    const SizedBox(width: 16,),

                                    Expanded(
                                        child: ElevatedButton(
                                          onPressed: ()
                                          {
                                            if(!isDriverAvaliable)
                                              {
                                                //go online
                                                goOnlineNow();


                                                //share live location
                                                setAndGetLocationUpdates();


                                                Navigator.pop(context);

                                                setState(() {
                                                  colorToShow=Colors.pink;
                                                  titleToShow="GO OFFLINE NOW";
                                                  isDriverAvaliable =true;
                                                });
                                              }
                                            else{
                                              //go offline
                                              goOfflineNow();


                                              Navigator.pop(context);
                                              setState(() {
                                                colorToShow=Colors.green;
                                                titleToShow="GO ONLINE NOW";
                                                isDriverAvaliable=false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: (titleToShow=="GO ONLINE NOW")
                                                ? Colors.green : Colors.pink,
                                          ),
                                          child: const Text(
                                              "CONFIRM"
                                          ),
                                        )
                                    ),



                                  ],
                                )

                              ],
                            ),
                          );
                        }
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorToShow,
                  ),
                  child: Text(
                    titleToShow,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
