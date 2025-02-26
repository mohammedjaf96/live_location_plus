import 'dart:math';
import 'package:live_location_plus/src/controllers/Location_permission_service.dart';
import 'package:live_location_plus/src/models/location_data.dart';
import 'package:location/location.dart';
import '../permissionExceptions/permission_exception.dart';
import 'dart:async';


class LocationService {
  PositionData? _locationData;
  final LocationPermissionService _locationPermissionService = LocationPermissionService();

  // StreamController to notify location updates
  final StreamController<PositionData> _locationStreamController = StreamController.broadcast();

  /// Expose the stream to listen for location updates
  Stream<PositionData> get locationStream => _locationStreamController.stream;

  Future<void> init({
    bool currentLocation = false,
    bool foregroundLiveLocation = false,
    bool backgroundLiveLocation = false,
    double distanceFilter = 20,
    int interval = 60000,
  }) async {
    PermissionException hasPermission = await _locationPermissionService.init(
      currentLocation: currentLocation,
      foregroundLiveLocation: foregroundLiveLocation,
      backgroundLiveLocation: backgroundLiveLocation,
    );

    if (hasPermission.isGranted) {
      if (currentLocation && !foregroundLiveLocation && !backgroundLiveLocation) {
        await _changeStatusOfBackgroundWorking(false, interval: interval, distanceFilter: distanceFilter);
        await _setCurrentLocation();
      }
      if (currentLocation && foregroundLiveLocation && !backgroundLiveLocation) {
        await _changeStatusOfBackgroundWorking(false);
        _setLiveLocation();
      }
      if (currentLocation && foregroundLiveLocation && backgroundLiveLocation) {
        await _changeStatusOfBackgroundWorking(true);
        _setLiveLocation();
      }
    }else{
      await _changeStatusOfBackgroundWorking(false);
    }
  }

  Future<void> _setCurrentLocation({LocationData? newData, double? newRotation}) async {
    late LocationData data;
    if (newData == null) {
      Location location = Location();
      data = await location.getLocation();
    } else {
      data = newData;
    }

    if (_locationData != null) {
      _locationData!.lastLocation = _locationData!.currentLocation;
      _locationData!.currentLocation = LocationDetails(
        latitude: data.latitude ?? 0,
        longitude: data.longitude ?? 0,
        rotation: _calculateBearing(
          _locationData!.currentLocation.latitude,
          _locationData!.currentLocation.longitude,
          _locationData!.lastLocation.latitude,
          _locationData!.lastLocation.longitude,
        ),
      );
    }
    else {
      _locationData = PositionData(
        currentLocation: LocationDetails(
          latitude: data.latitude ?? 0,
          longitude: data.longitude ?? 0,
          rotation: data.heading ?? 0,
        ),
        lastLocation: LocationDetails(
          latitude: data.latitude ?? 0,
          longitude: data.longitude ?? 0,
          rotation: data.heading ?? 0,
        ),
      );
    }

    // Notify listeners about the location update
    _locationStreamController.add(_locationData!);
  }

  void _setLiveLocation() {
    Location location = Location();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      await _setCurrentLocation(newData: currentLocation, newRotation: 0);
    });
  }

  Future<void> _changeStatusOfBackgroundWorking(bool onBackground, {int? interval, double? distanceFilter}) async {
    Location location = Location();
    await location.enableBackgroundMode(enable: onBackground);
    await location.changeSettings(
      accuracy: onBackground ? LocationAccuracy.low : LocationAccuracy.high,
      interval: interval ?? (onBackground ? 10 : 60000),
      distanceFilter: distanceFilter ?? (onBackground ? 5 : 20),
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double toRadians(double degrees) => degrees * (pi / 180);
    double toDegrees(double radians) => radians * (180 / pi);

    double deltaLon = toRadians(lon2 - lon1);
    double lat1Rad = toRadians(lat1);
    double lat2Rad = toRadians(lat2);

    double y = sin(deltaLon) * cos(lat2Rad);
    double x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLon);

    double bearing = toDegrees(atan2(y, x));
    return (bearing + 360) % 360;
  }

  /// Close the stream when no longer needed
  Future<void> dispose() async {
    _locationStreamController.close();
    await _locationPermissionService.init(currentLocation: false, foregroundLiveLocation: false, backgroundLiveLocation: false,);
    await _changeStatusOfBackgroundWorking(false);
  }


  Future<LocationData> getLocation()async{
    Location location = Location();
    return await location.getLocation();
  }
}
