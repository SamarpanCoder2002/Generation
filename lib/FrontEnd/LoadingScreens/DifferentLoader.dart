import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loaders extends StatefulWidget {
  int _loaderIndex;

  Loaders(this._loaderIndex);

  @override
  _LoadersState createState() => _LoadersState(this._loaderIndex);
}

class _LoadersState extends State<Loaders> with TickerProviderStateMixin {
  int _loaderIndex;

  _LoadersState([this._loaderIndex = 1]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loadingIndexing(),
      ),
    );
  }

  Widget loadingIndexing() {
    if (_loaderIndex == 1) {
      return SpinKitWave(
        color: Color.fromRGBO(0, 0, 250, 0.8),
        size: 50.0,
        controller: AnimationController(
            vsync: this, duration: const Duration(milliseconds: 800)),
      );
    }
  }
}
