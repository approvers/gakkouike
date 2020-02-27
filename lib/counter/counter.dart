import 'package:flutter/material.dart';

class CounterRootView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("あとでなんとかする"),),
      body: Container(
        child: Center(
          child: Text("まだだよカス"),
        ),
      ),
    );
  }
}