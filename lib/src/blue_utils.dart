import 'package:flutter_blue/flutter_blue.dart';

BluetoothDevice findDeviceFromList({
  String deviceName,
  List<BluetoothDevice> deviceList,
}) {
  /// retrieve device with deviceName from the list of devices.
  return deviceList.firstWhere((d) => d.name == deviceName, orElse: () => null);
}

Future<BluetoothDevice> getDeviceIfConnected({String name}) async {
  return findDeviceFromList(
    deviceName: name,
    deviceList: await FlutterBlue.instance.connectedDevices,
  );
}

Future<void> waitUntilDisconnected(BluetoothDevice device) async {
  // await device.state.firstWhere((s) => s != BluetoothDeviceState.connected);
  await device.state.firstWhere((s) {
    print(s);
    return s == BluetoothDeviceState.disconnected;
  });
}
