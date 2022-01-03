import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smart_fridge/screens/object_detection/bounding_box.dart';
import 'package:smart_fridge/screens/object_detection/camera.dart';
import 'dart:math' as math;
import 'package:tflite/tflite.dart';

class LiveFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  LiveFeed(this.cameras);
  @override
  _LiveFeedState createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  List<String> selected = [];
  initCameras() async {

  }
  loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/model/ssd_mobilenet.tflite",
      labels: "assets/model/labels.txt",
    );
  }
  /* 
  The set recognitions function assigns the values of recognitions, imageHeight and width to the variables defined here as callback
  */
  setRecognitions(recognitions, imageHeight, imageWidth) {
    if(mounted){
      setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
    }
  }

  @override
  void initState() { 
    super.initState();
    loadTfModel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Real Time Object Detection"),
        backgroundColor: Colors.teal,
        // actions: [
        //   ElevatedButton(onPressed: (){
        //     Navigator.pop(context, selected);
        //   }, child: Text('done')),
        // ],
      ),
      body: Stack(
        children: <Widget>[
          CameraFeed(widget.cameras, setRecognitions),
          BoundingBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: 
                ListView.builder(
                  //controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _recognitions.length,
                  itemBuilder: (context, index) {
                    dynamic item = _recognitions[index];
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: ChoiceChip(
                        label: Text(item["detectedClass"]), 
                        selected: false,//selected.contains(item["detectedClass"]),
                        selectedColor : Colors.red,
                        onSelected: (value) {
                          Navigator.pop(context, item["detectedClass"]);
                          //selected.add(item["detectedClass"]);
                        },
                        padding: EdgeInsets.all(4),
                      ),
                    );
                  },
                ),),
            ],
          )
        ],
      ),
    );
  }
}