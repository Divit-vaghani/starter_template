import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:starter_template/injectable/injectable.dart';

class BaseDevice {
  String brand;
  String model;
  String manufacturer;
  String appver;
  String appvercode;
  String deviceType;

  BaseDevice({
    required this.brand,
    required this.model,
    required this.manufacturer,
    required this.appver,
    required this.appvercode,
    required this.deviceType,
  });

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'manufacturer': manufacturer,
      'appver': appver,
      'appvercode': appvercode,
      'deviceType': deviceType,
    };
  }
}

class BaseDeviceInfoUtils {
  static Future<BaseDevice> baseDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return _androidInfo(info);
    }
    final info = await deviceInfo.iosInfo;
    return _iosInfo(info);
  }

  static BaseDevice _iosInfo(IosDeviceInfo info) {
    return BaseDevice(
      model: info.model,
      appver: getIt<PackageInfo>().version,
      appvercode: getIt<PackageInfo>().buildNumber,
      manufacturer: 'apple',
      brand: 'apple',
      deviceType: 'ios',
    );
  }

  static BaseDevice _androidInfo(AndroidDeviceInfo info) {
    return BaseDevice(
      brand: info.brand,
      model: info.model,
      manufacturer: info.manufacturer,
      appver: getIt<PackageInfo>().version,
      appvercode: getIt<PackageInfo>().buildNumber,
      deviceType: 'android',
    );
  }
}
