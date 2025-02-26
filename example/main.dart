import 'package:live_location_plus/live_location_plus.dart';

void main() {
  LocationService locationService = LocationService();

  locationService.init(
    currentLocation: true, // if you set "currentLocation" equal "false" you can't use any location service in app
    foregroundLiveLocation: true, // if you set "foregroundLiveLocation" equal "false" the live location update only on foreground
    backgroundLiveLocation: false, // replace with "true" if you want get live location on background
  );


  locationService.locationStream.listen((position) {
    print("New Location: ${position.currentLocation.latitude}, ${position.currentLocation.longitude}");
  });
}