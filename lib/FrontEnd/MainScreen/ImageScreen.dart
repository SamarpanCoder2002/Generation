import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:circle_list/circle_list.dart';
import 'package:generation/FrontEnd/Store/cameraOperation.dart';

class ApplicationList extends StatefulWidget {
  @override
  _ApplicationListState createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: CircleList(
            initialAngle: 55,
            outerRadius: MediaQuery.of(context).size.width / 2.2,
            innerRadius: MediaQuery.of(context).size.width / 5,
            showInitialAnimation: true,
            innerCircleColor: Colors.white,
            outerCircleColor: Color.fromRGBO(0, 0, 0, 0.1),
            origin: Offset(0, 0),
            rotateMode: RotateMode.allRotate,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    primary: Color.fromRGBO(0, 0, 0, 0.0),
                    onPrimary: Colors.white70,
                    shape: CircleBorder(),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhotoCapture()));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 40,
                        color: Colors.green,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    primary: Color.fromRGBO(0, 0, 0, 0.0),
                    onPrimary: Colors.white70,
                    shape: CircleBorder(),
                  ),
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.video_call_sharp,
                        size: 40,
                        color: Colors.green,
                      ),
                      Text(
                        'Video',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    primary: Color.fromRGBO(0, 0, 0, 0.0),
                    onPrimary: Colors.white70,
                    shape: CircleBorder(),
                  ),
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.call,
                        size: 40,
                        color: Colors.green,
                      ),
                      Text(
                        'Call',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    )),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    primary: Color.fromRGBO(0, 0, 0, 0.0),
                    onPrimary: Colors.white70,
                    shape: CircleBorder(),
                  ),
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 40,
                        color: Colors.green,
                      ),
                      Text(
                        'Location',
                        style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
