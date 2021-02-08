import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_flutter_blue/easy_flutter_blue.dart';
import '../materials/loading.dart';

class DevicePage extends StatefulWidget {
  /// Detail page of a connected device

  const DevicePage({Key key, @required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  var notifier;
  String receivedValue;

  Widget _mainBody(dynamic files, BluetoothDeviceState state) {
    switch (state) {
      case BluetoothDeviceState.connecting:
        return DefaultLoading(
          text1: "연결 중 입니다.",
          text2: "오래 걸릴 경우 재시도 하거나 장치를 초기화 해주세요.",
        );
      case BluetoothDeviceState.disconnecting:
        return DefaultLoading(
          text1: "연결 해제 중 입니다.",
          text2: "오래 걸릴 경우 뒤로 가기를 눌러주세요.",
        );
      case BluetoothDeviceState.connected:
        return StreamBuilder<List<BluetoothService>>(
            stream: widget.device.services,
            initialData: [],
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return DefaultLoading(
                  text1: "연결 중 입니다.",
                  text2: "오래 걸릴 경우 재시도 하거나 장치를 초기화 해주세요.",
                );
              }
              BluetoothService uartService =
                  snapshot.data.firstWhere((service) {
                String uuid = service.uuid.toString().toUpperCase();
                String name = files.uuidToService[uuid]['name'];
                return name.contains("UART");
              }, orElse: () => null);

              if (uartService == null) return DefaultLoading();

              BluetoothCharacteristic readChar =
                  uartService.characteristics.firstWhere((char) {
                String uuid = char.uuid.toString().toUpperCase();
                String name = files.uuidToCharacteristic[uuid]['name'];
                return name.contains("TX");
              }, orElse: () => null);

              if (readChar == null) return DefaultLoading();

              BluetoothCharacteristic writeChar =
                  uartService.characteristics.firstWhere((char) {
                String uuid = char.uuid.toString().toUpperCase();
                String name = files.uuidToCharacteristic[uuid]['name'];
                return name.contains("RX");
              }, orElse: () => null);

              if (writeChar == null) return DefaultLoading();

              Widget _orderButton(int number) {
                return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                    child: TextButton(
                      child: Text(number.toString()),
                      onPressed: () async {
                        await readChar.setNotifyValue(true);
                        if (notifier != null) notifier.cancel();
                        notifier = readChar.value.listen((value) {
                          setState(() {
                            receivedValue = utf8.decode(value);
                          });
                        });
                        await writeChar.write(utf8
                            .encode('PB${number.toString().padLeft(2, '0')};'));
                      },
                    ));
              }

              Widget _orderButtonLED(int number) {
                return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    child: TextButton(
                      child: Text(number > 0 ? number.toString() : "LED off"),
                      onPressed: () async {
                        await readChar.setNotifyValue(true);
                        if (notifier != null) notifier.cancel();
                        notifier = readChar.value.listen((value) {
                          setState(() {
                            receivedValue = utf8.decode(value);
                            print(receivedValue);
                          });
                        });
                        await writeChar.write(utf8
                            .encode('S${number.toString().padLeft(2, '0')};'));
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.amberAccent),
                    ));
              }

              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [1, 2, 3, 4, 5]
                            .map((e) => _orderButton(e))
                            .toList()),
                    Center(
                        child: Container(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Text(getIcon(receivedValue),
                                style: TextStyle(fontSize: 60)))),
                    _orderButtonLED(0),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [1, 2, 3, 4, 5]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [6, 7, 8, 9, 10]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [11, 12, 13, 14, 15]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [16, 17, 18, 19, 20]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [21, 22, 23, 24, 25]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [26, 27, 28]
                            .map((e) => _orderButtonLED(e))
                            .toList()),
                  ],
                ),
              );
            });
      case BluetoothDeviceState.disconnected:
      default:
        return DefaultLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = BlueAssetsContainer.of(context).files;

    return StreamBuilder(
        stream: widget.device.state,
        builder: (c, snapshot) {
          switch (snapshot.data) {
            case BluetoothDeviceState.connected:
              widget.device.discoverServices();
              break;
          }

          return Scaffold(

              /// App navigation bar
              appBar: AppBar(
                title: Text(widget.device.name),
                backgroundColor: Colors.lightGreen,
                actions: <Widget>[
                  _toggleConnection(
                    widget.device,
                    snapshot.data,
                    notifier,
                    () => Navigator.of(context).pop(),
                  )
                ],
              ),
              body: _mainBody(files, snapshot.data));
        });
  }
}

String getIcon(String receivedValue) {
  switch (receivedValue) {
    case "Heart":
      return "❤";
    case "Smile":
      return '😊';
    case "HandClap":
      return '👏';
    case "AJu":
      return '🙏🏻';
    case "OnMansei":
      return '🙌';
    default:
      return "";
  }
}

Widget _toggleConnection(
  BluetoothDevice device,
  BluetoothDeviceState state,
  dynamic notifier,
  dynamic pop,
) {
  String text;
  Function onPressed = () {};

  switch (state) {
    case BluetoothDeviceState.connecting:
      text = "연결 중";
      break;
    case BluetoothDeviceState.disconnecting:
      text = "연결 해제 중";
      break;
    case BluetoothDeviceState.connected:
      text = "연결 해제";
      onPressed = () async {
        if (notifier != null) await notifier.cancel();
        device.disconnect();
      };
      break;
    case BluetoothDeviceState.disconnected:
      text = "연결 해제 중";
      Future.delayed(Duration.zero, () {
        /// Execute pop navigation in the next tick
        /// This is an odd trick...
        pop();
      });
      break;
    default:
      text = "대기 중";
  }

  return TextButton(
    onPressed: onPressed,
    child: Text(text, style: TextStyle(fontSize: 16)),
  );
}
