import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestTrackingPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.activityRecognition,
    ].request();

    final PermissionStatus locationStatus =
        statuses[Permission.locationWhenInUse] ?? PermissionStatus.denied;

    final PermissionStatus activityStatus =
        statuses[Permission.activityRecognition] ?? PermissionStatus.denied;

    return locationStatus.isGranted && activityStatus.isGranted;
  }

  static Future<bool> isTrackingPermissionGranted() async {
    final PermissionStatus locationStatus =
        await Permission.locationWhenInUse.status;

    final PermissionStatus activityStatus =
        await Permission.activityRecognition.status;

    return locationStatus.isGranted && activityStatus.isGranted;
  }

  static Future<bool> openSettings() async {
    return openAppSettings();
  }
}
