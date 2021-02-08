import 'package:flutter/material.dart';

class BlueOffPage extends StatelessWidget {
  /// Page that shows up when bluetooth is turned off

  const BlueOffPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightGreen,
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(Icons.bluetooth_disabled, size: 200.0, color: Colors.white54),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '블루투스가 꺼져있습니다.',
              style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '블루투스를 켜주세요.',
              style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
            ),
          ),
        ])));
  }
}
