# live location plus

A powerful and easy-to-use package for real-time location tracking in Flutter applications. live_location_plus helps developers efficiently manage foreground and background location updates with optimized performance.

![Logo](https://storage.googleapis.com/cms-storage-bucket/847ae81f5430402216fd.svg)


## Features

✅ Get current location  
✅ Enable live location updates (foreground & background)  
✅ Efficient battery optimization  
✅ Easy integration with iod/android
✅ Automatic location permission handling


## Installation

### Android
No additional setup is required.

### iOS
To enable background location updates, add the following to your **Info.plist** file:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>processing</string>
</array>


## Getting Started

To install, add it to your `pubspec.yaml` file:

```
dependencies:
  live_location_plus:  

```

```dart
import 'package:live_location_plus/live_location_plus.dart';
```

## Usage/Examples

```dart
import 'package:live_location_plus/live_location_plus.dart';

void main() {
  LocationService locationService = LocationService();

  locationService.init(
    currentLocation: true,
    foregroundLiveLocation: true,
    backgroundLiveLocation: false,
  );


  locationService.locationStream.listen((position) {
    print("New Location: ${position.currentLocation.latitude}, ${position.currentLocation.longitude}");
  });
}
```


## Support

For support, email mohammedjjaff@gmail.com.com .


## Follow me at Instagram

- Instagram : https://instagram.com/m9_6m?igshid=YTQwZjQ0NmI0OA==

