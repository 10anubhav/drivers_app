import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drivers_app/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
      var connectionResult = await Connectivity().checkConnectivity();

      if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
        {
          if(!context.mounted)return;
          displaySnackBar("Internet is not Working, Check Your connection and Try Again", context);
        }
  }

  displaySnackBar(String messageText , BuildContext context)
  {
    var snackBar = SnackBar(content: Text( messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdatesForHomePage()
  {
    positionStreamHomePage!.pause();

    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  turnOnLocationUpdatesForHomePage()
  {
    positionStreamHomePage!.resume();

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

}