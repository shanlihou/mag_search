import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> getAndroidPermission() async {
  final DeviceInfoPlugin info =
      DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
  final AndroidDeviceInfo androidInfo = await info.androidInfo;
  var strVersion = androidInfo.version.release;
  if (strVersion.contains('.')) {
    strVersion = strVersion.split('.').first;
  }
  final int androidVersion = int.parse(strVersion);

  if (androidVersion >= 13) {
    final request = await [
      Permission.videos,
      Permission.photos,
      Permission.audio,
    ].request(); //import 'package:permission_handler/permission_handler.dart';

    return request.values.every((status) => status == PermissionStatus.granted);
  } else {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}

Future<bool> getStoragePermission() async {
  bool ret = true;
  if (Platform.isAndroid) {
    ret = await getAndroidPermission();
  } else {
    // TODO: check iOS permission
    return ret;
  }

  return ret;
}

Future<bool> initDirectory() async {
  if (!await getStoragePermission()) {
    return false;
  }

  if (Platform.isAndroid) {
    var externalDir = await getExternalStorageDirectory();
    var applicationDir = await getApplicationDocumentsDirectory();
    Directory.current = externalDir ?? applicationDir;
  } else if (Platform.isWindows) {
    // var externalDir = await getExternalStorageDirectory();
    // var applicationDir = await getApplicationDocumentsDirectory();
  } else if (Platform.isIOS) {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    Directory.current = appDocumentsDir;
  }

  return true;
}
