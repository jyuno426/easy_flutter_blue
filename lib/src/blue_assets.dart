import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';
import 'dart:async';

class BlueAssets extends StatelessWidget {
  /// The main wrapper for handling blue assets and several states.

  const BlueAssets({
    Key key,
    this.loadingDuration = 2000,
    @required this.child,
  }) : super(key: key);

  final int loadingDuration; // in ms
  final Widget child;

  @override
  Widget build(BuildContext context) {
    /// First load bluetooth database (json) files from local.
    return FutureBuilder(
        future: _loadBlueFiles(loadingDuration: loadingDuration),
        builder: (c, AsyncSnapshot assetSnapshot) {
          /// Then stream bluetooth state, which can change.
          return StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, stateSnapshot) {
                ///
                return BlueAssetsContainer(
                  isBlueOn: stateSnapshot.data == BluetoothState.on,
                  files: _BlueFiles.buildFrom(assetSnapshot.data),
                  child: child,
                );
              });
        });
  }
}

class BlueAssetsContainer extends InheritedWidget {
  /// InheritedWidget (similar to storage)

  const BlueAssetsContainer({
    @required this.isBlueOn,
    @required this.files,
    @required Widget child,
  }) : super(child: child);

  /// Assets in one object
  final bool isBlueOn; // where the bluetooth is turned on.
  final _BlueFiles files;

  /// 'Update disabled' since assets are all immutable
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static BlueAssetsContainer of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlueAssetsContainer>();
  }
}

Future<List> _loadBlueFiles({int loadingDuration = 2000}) async {
  /// Load assets asynchronously from local json files.
  print("Waiting for loading bluetooth assets...");

  /// Group multiple futures into one future.
  return Future.delayed(
      Duration(milliseconds: loadingDuration),
      () => Future.wait(['service', 'characteristic', 'descriptor']
          .map((e) async => rootBundle.loadString(
                'packages/easy_flutter_blue/assets/${e}_uuids.json',
              ))
          .map((e) async => json.decode(await e))));
}

class _BlueFiles {
  /// Definition of bluetooth files

  /// Dictionaries of device's uuid to its info.
  /// The database is from:
  /// github.com/NordicSemiconductor/bluetooth-numbers-database
  Map<String, Map<String, String>> uuidToService;
  Map<String, Map<String, String>> uuidToCharacteristic;
  Map<String, Map<String, String>> uuidToDescriptor;

  _BlueFiles({
    @required this.uuidToService,
    @required this.uuidToCharacteristic,
    @required this.uuidToDescriptor,
  });

  factory _BlueFiles.buildFrom(var rawFiles) {
    /// Build the _BlueFiles object from rawFiles
    /// Define how to parse and reform variables.

    /// For null-safety
    if (rawFiles == null) return null;

    List<Map<String, Map<String, String>>> assets = [];

    for (var asset in rawFiles) {
      Map<String, Map<String, String>> uuidMap = {};
      for (var info in asset) {
        String uuid = info['uuid'].length == 4
            ? '0000${info['uuid']}-0000-1000-8000-00805F9B34FB'
            : info['uuid'];
        assert(uuid.length == 36);

        uuidMap[uuid] = new Map.from(info);
        uuidMap[uuid].remove('uuid');
      }
      assets.add(uuidMap);
    }

    return new _BlueFiles(
      uuidToService: assets[0],
      uuidToCharacteristic: assets[1],
      uuidToDescriptor: assets[2],
    );
  }
}
