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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                                  print(msg);
                                });

                                drone.sendData("command");
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                drone.sendData("takeoff");

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
        )
      ],
    );
  }
}

class ControlButton extends StatelessWidget {
  final DjiDrone drone;
  final String commandToSend;
  final String text;

  const ControlButton({
    super.key, 
    required this.drone, 
    required this.commandToSend, 
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        drone.sendData(commandToSend);
      },
      child: Text(text)
    );
  }
}
