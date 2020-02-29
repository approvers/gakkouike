import 'package:flutter/material.dart';

class ConfigRootView extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("あとでなんとかする"),),
      body: Container(
        child: _ConfigPage()
      ),
    );
  }
}

class _ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<_ConfigPage>{
  //TODO: 実装しろカス
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadConfig(),
    );
  }

  Future<Widget> loadConfig(){
    // ここにロード処理

  }
}
