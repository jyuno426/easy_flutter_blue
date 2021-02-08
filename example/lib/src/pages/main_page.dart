import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_flutter_blue/easy_flutter_blue.dart';

import 'device_page.dart';
import '../materials/loading.dart';

class MainPage extends StatefulWidget {
  /// Main page with temporary ui.
  /// Currently, plan to scan and connect to HJ light stick device
  /// automatically when users pressed a button for plausible ux.
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// These states are ui-specific features for loading screen.
  /// Not exactly matched with bluetooth scanning/connecting states.
  int timeout = 5;
  bool isScanning = false;
  bool isConnecting = false;
  bool isError = false;
  String errorMessage = "";

  /// Device identifier that we want to find and connect.
  /// It may be uuid or MAC-address or something else
  String deviceName = "Bluefruit52";

  void onIdle() => setState(() {
        isScanning = false;
        isConnecting = false;
        isError = false;
      });

  void onScan() => setState(() {
        isScanning = true;
        isConnecting = false;
        isError = false;
      });

  void onConnect() => setState(() {
        isScanning = false;
        isConnecting = true;
        isError = false;
      });

  void onError(error) => setState(() {
        isScanning = false;
        isConnecting = false;
        isError = true;
        errorMessage = error.toString();
      });

  @override
  Widget build(BuildContext context) {
    void routeToDevicePage(BluetoothDevice device) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => DevicePage(device: device),
      ));
    }

    void _onConnectButtonPressed() async {
      BluetoothDevice device;

      /// Initialize states
      onScan();

      /// First, checks if already connected to the desired device
      device = await getDeviceIfConnected(name: deviceName);

      if (device != null) {
        /// Device is already connected!
        await Future.delayed(Duration(milliseconds: 1200), () async {
          /// artificial loading
          onConnect();
          await Future.delayed(Duration(milliseconds: 1200), onIdle);
        });
        routeToDevicePage(device);
        return;
      }

      /// If not, should manually find.
      await autoConnectToDevice(
          deviceName: deviceName,
          scanTimeout: timeout,
          connectTimeout: timeout,
          onScanStart: onScan,
          onScanError: onError,
          onDeviceNotFound: () => onError("장치를 찾지 못했습니다. 다시 시도해주세요."),
          onConnectStart: onConnect,
          onConnectError: onError,
          onConnectSucceed: (device) {
            onIdle();
            routeToDevicePage(device);
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '효정 패드 연결하기',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: _mainBody(isScanning, isConnecting, isError, errorMessage),
      floatingActionButton: _connectButton(
        isScanning || isConnecting,
        onPressed: _onConnectButtonPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Main body for MainPage
/// Loading or default message
Widget _mainBody(
  bool isScanning,
  bool isConnecting,
  bool isError,
  String errorMessage,
) {
  if (isError) {
    print(errorMessage);
    return Center(
      child: Text(
        errorMessage,
        style: TextStyle(fontSize: 16),
      ),
    );
  } else if (isScanning) {
    return DefaultLoading(text1: "장치를 탐색 중 입니다.");
  } else if (isConnecting) {
    return DefaultLoading(text1: "장치를 찾았습니다.", text2: "연결 중 입니다.");
  } else {
    return Center(
      child: Text(
        "아래 버튼을 눌러 연결해보세요.",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// Button to scan nearby bluetooth devices
Widget _connectButton(bool isLoading, {onPressed}) {
  final double iconSize = 30;
  final double fontSize = 24;
  final Size minimumSize = Size(240, 0);
  final OutlinedBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  );

  if (isLoading) {
    return TextButton.icon(
      onPressed: null,
      icon: Icon(Icons.search, size: iconSize),
      label: Text(
        "연결 중...",
        style: TextStyle(fontSize: fontSize),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.black12,
        minimumSize: minimumSize,
        shape: shape,
      ),
    );
  } else {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.search, size: iconSize),
      label: Text(
        "연결하기",
        style: TextStyle(fontSize: fontSize),
      ),
      style: TextButton.styleFrom(
        minimumSize: minimumSize,
        shape: shape,
      ),
    );
  }
}
