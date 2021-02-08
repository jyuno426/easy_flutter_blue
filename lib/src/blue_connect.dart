import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'blue_utils.dart';

Future<void> autoConnectToDevice({
  String deviceName,
  int scanTimeout, // in seconds
  int connectTimeout, // in seconds
  onScanStart,
  onDeviceNotFound,
  onScanError,
  onConnectStart,
  onConnectSucceed,
  onConnectError,
}) async {
  /// Scan and connect to the device automatically specified as deviceName.
  BluetoothDevice device;

  /// Start scan nearby bluetooth devices
  if (onScanStart != null) onScanStart();
  FlutterBlue.instance
      .startScan(timeout: Duration(seconds: max(scanTimeout, 5)))
      .then((result) {
    /// Should return here from await for loop if device is not found.
    if (onDeviceNotFound != null && device == null) onDeviceNotFound();
  }).catchError((error) {
    /// Error happened while scanning (such as timeout)
    if (onScanError != null) onScanError(error);
  });

  /// (*) Retrieve scanResults and find the desired device.
  /// Delay several seconds for plausible loading.
  await Future.delayed(Duration(seconds: 2), () async {
    await for (var results in FlutterBlue.instance.scanResults) {
      /// Update device
      device = findDeviceFromList(
        deviceName: deviceName,
        deviceList: results.map((r) => r.device).toList(),
      );

      /// If device is found, escape await for.
      if (device != null) break;
    }
  });

  assert(device != null);
  print("Device found");

  /// Device found and let's connect to it.
  if (onConnectStart != null) onConnectStart();

  /// Connect to the device
  /// Delay 1 second for plausible loading
  await Future.delayed(Duration(seconds: 2), () {
    /// Note that .connect method is fixed from original package
    /// See: https://github.com/jyuno426/flutter_blue/commits/master/lib/src/bluetooth_device.dart
    device.connect(autoConnect: false).then((_) {
      /// Connect succeed
      if (onConnectSucceed != null) onConnectSucceed(device);
    }).catchError((error) {
      /// Error happened while connecting (such as timeout)
      if (onConnectError != null) onConnectError(error);
    });
  });
}
