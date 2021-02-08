import 'package:flutter/material.dart';
import '../materials/loading.dart';

class LoadingPage extends StatelessWidget {
  /// Loading Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// App navigation bar
      // appBar: AppBar(
      //   title: Text('Loading Page'),
      //   backgroundColor: Colors.lightGreen,
      // ),

      /// Main body with circular progress
        body: DefaultLoading(
          text1: "앱을 실행 중 입니다.",
          text2: "잠시만 기다려 주세요.",
        ));
  }
}
