class PositionData {
  LocationDetails currentLocation;
  LocationDetails lastLocation;

  PositionData({required this.currentLocation,required this.lastLocation});
}




class LocationDetails {
  double latitude;
  double longitude;
  double rotation;

  LocationDetails({required this.latitude,required this.longitude,required this.rotation});
}
