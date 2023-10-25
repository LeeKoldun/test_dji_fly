import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:test_dji_fly/drone/drone.dart';

void main() {  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool isStarted = false;
  bool lock = false;
  String command = "";
  late DjiDrone drone;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if(isStarted) VideoStream(videoStream: drone.videoStream),
            TextField(
              onChanged: (text) {
                command = text;
              },
            ),
            ElevatedButton(
              onPressed: !isStarted
                  ? null
                  : () {
                      drone.sendData(command);
                    },
              child: const Text("Send command"),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Column(
                  children: [
                    ElevatedButton(
                        onPressed: lock
                            ? null
                            : () async {
                                setState(() {
                                  lock = true;
                                });

                                drone = await DjiDrone.init(
                                  droneIp: "192.168.10.1",
                                  port: 8889,
                                );

                                drone.reciever.listen((msg) {
                                  msg = String.fromCharCodes((msg as Datagram).data);

                                  print("Command info: $msg");
                                });
                                // drone.videoStream.listen((msg) {
                                //   msg = String.fromCharCodes((msg as Datagram).data);

                                //   print("Video info: $msg");
                                // });

                                drone.sendData("command");
                                await Future.delayed(const Duration(milliseconds: 500));
                                drone.sendData("battery?");
                                // drone.sendData("takeoff");

                                setState(() {
                                  isStarted = true;
                                });
                              },
                        child: const Text("Start")),
                    ElevatedButton(
                        onPressed: !isStarted
                            ? null
                            : () {
                                drone.sendData("land");
                                drone.dispose();
                                setState(() {
                                  isStarted = false;
                                  lock = false;
                                });
                              },
                        child: const Text("Stop")),
                  ],
                ),
                if(isStarted) Controls(drone: drone),

              ],
            ),
          ],
        )),
      ),
    );
  }
}

class VideoStream extends StatefulWidget {
  final Stream videoStream;

  const VideoStream({
    super.key,
    required this.videoStream,
  });

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  String? pngBytes;
  
  @override
  void initState() {
    super.initState();
    widget.videoStream.listen((data) async {
      data = data as Datagram;
      var codec = await instantiateImageCodec(data.data);
      var frame = await codec.getNextFrame();
      var byteData = await frame.image.toByteData(format: ImageByteFormat.png);
      setState(() {
        pngBytes = base64Encode(byteData!.buffer.asUint8List());
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return pngBytes == null ? const SizedBox() : Image.memory(base64Decode(pngBytes!));
  }
}

class Controls extends StatelessWidget {
  final DjiDrone drone;

  const Controls({super.key, required this.drone});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ControlButton(
              drone: drone, 
              commandToSend: "forward 20", 
              text: "Forward"
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                ControlButton(
                  drone: drone, 
                  commandToSend: "left 20", 
                  text: "Left"
                ),

                ControlButton(
                  drone: drone, 
                  commandToSend: "right 20", 
                  text: "Right"
                ),
              ],
            ),
            ControlButton(
              drone: drone, 
              commandToSend: "back 20", 
              text: "Back"
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            ControlButton(
              drone: drone, 
              commandToSend: "up 20", 
              text: "Up"
            ),
            ControlButton(
              drone: drone, 
              commandToSend: "down 20", 
              text: "Down"
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            ControlButton(
              drone: drone, 
              commandToSend: "streamon", 
              text: "Camera on"
            ),
            ControlButton(
              drone: drone, 
              commandToSend: "streamoff", 
              text: "Camera off"
            ),
          ],
        ),

      ],
    );
  }
}

class ControlButton extends StatelessWidget {
  final DjiDrone drone;
  final String commandToSend;
  final String text;
  final VoidCallback? onPressed;

  const ControlButton({
    super.key, 
    required this.drone, 
    required this.commandToSend, 
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        drone.sendData(commandToSend);
        onPressed?.call();
      },
      child: Text(text)
    );
  }
}
