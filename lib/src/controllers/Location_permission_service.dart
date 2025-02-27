
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import '../permissionExceptions/permission_exception.dart';

class LocationPermissionService {


  Location location = Location();

  Future<PermissionException> requestPermissionForCurrentLocation()async{
    // It's checking the current permission. If it's denied or permanently denied, request permission.
    PermissionStatus status = await location.hasPermission();
    if (status == PermissionStatus.denied) {
      await location.requestPermission().then((e){
        status = e;
      });
    }
    if(status == PermissionStatus.deniedForever){
      await permission_handler.openAppSettings().then((e) async {
        status = await location.hasPermission();
      });
    }

    if (status == PermissionStatus.granted) {
      return PermissionException("Current location permission status is granted", true);
    } else {
      return PermissionException("Current location permission status is denied", false);
    }

  }

  Future<PermissionException> requestPermissionForForegroundLiveLocation()async{

    // It's checking the location always permission. If it's denied or permanently denied, request permission.

    late bool foregroundLiveLocationStatus;
    PermissionException currentLocationPermissionHandler = await requestPermissionForCurrentLocation();

    var batteryOptimizations = await permission_handler.Permission.ignoreBatteryOptimizations.request();
    if (batteryOptimizations.isDenied) {
      await permission_handler.Permission.ignoreBatteryOptimizations.request();
    }

    if(currentLocationPermissionHandler.isGranted){
      var locationAlwaysStatus = await permission_handler.Permission.locationAlways.status;
      if (locationAlwaysStatus == permission_handler.PermissionStatus.denied) {
        await permission_handler.Permission.locationAlways.request().then((e){
          locationAlwaysStatus = e;
        });
      }
      if(await permission_handler.Permission.locationAlways.isPermanentlyDenied){
        await permission_handler.openAppSettings().then((e) async {
          locationAlwaysStatus = await permission_handler.Permission.locationAlways.status;
        });
      }
      foregroundLiveLocationStatus = locationAlwaysStatus == permission_handler.PermissionStatus.granted;
      if (foregroundLiveLocationStatus) {
        return PermissionException("location always permission status is granted", true);
      } else {
        return PermissionException("location always permission status is denied", false);
      }
    }
    else{
      return PermissionException("location always permission status is denied", false);
    }


  }

  Future<PermissionException> changePermissionForBackgroundLiveLocation(bool value)async{

    // It's checking the location always and background live location permission. If it's denied or permanently denied, request permission.

    await location.enableBackgroundMode(enable: value);
    if (value) {
      return PermissionException("Background location turn on", value);
    } else {
      return PermissionException("Background location turn off", value);
    }

  }






  Future<PermissionException> init({bool currentLocation = false,bool foregroundLiveLocation = false,bool backgroundLiveLocation = false})async{
    bool locationService = await checkLocationServicePermission();
    if(locationService){
      if(currentLocation){
        PermissionException currentLocationPermissionHandler = await requestPermissionForCurrentLocation();
        if(currentLocationPermissionHandler.isGranted){
          if(foregroundLiveLocation){
            await requestPermissionForForegroundLiveLocation();
          }
          await changePermissionForBackgroundLiveLocation(backgroundLiveLocation);
          return PermissionException("Permission status is granted", true);
        }else{
          return currentLocationPermissionHandler;
        }
      }else{
        return PermissionException("Permission status is denied", false);
      }
    }else{
      return PermissionException("Location services are disabled.", false);
    }
  }








  // this function has checking the location service if it's enabled or not
  Future<bool> checkLocationServicePermission() async {
    bool? serviceEnabled = await location.serviceEnabled();
    if(serviceEnabled == false){
      serviceEnabled = await location.requestService();
    }
    // if null return false, by default
    return serviceEnabled;
  }



}