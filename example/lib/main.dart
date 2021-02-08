import 'package:flutter/material.dart';
import 'package:easy_flutter_blue/easy_flutter_blue.dart';
import 'src/pages/pages.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Wrap material app with BlueAssetsModule
    /// that contains json assets and streamed bluetooth state.
    return BlueAssets(
        loadingDuration: 1000, // in ms
        child: MaterialApp(
          title: "easy_flutter_blue_example",
          home: MyRouter(),

          /// Temporary theme
          theme: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.lightGreen,
                    textStyle: TextStyle(fontSize: 24)),
              ),
              primaryTextTheme: TextTheme()),
        ));
  }
}

class MyRouter extends StatelessWidget {
  /// This is just temporary router system.
  /// Can be manipulated for further use

  @override
  Widget build(BuildContext context) {
    if (!BlueAssetsContainer.of(context).isBlueOn) {
      /// Bluetooth is turned off.
      return BlueOffPage();
    }
    if (BlueAssetsContainer.of(context).files == null) {
      /// Wait for loading files.
      return LoadingPage();
    } else {
      /// Shows up main page.
      return MainPage();
    }
  }
}
