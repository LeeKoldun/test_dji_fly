import 'dart:io';

import 'package:udp/udp.dart';

class DjiDrone {
  final UDP sender;
  final UDP videoServer;
  final Stream reciever;
  final Stream videoStream;

  final String droneIp;
  final int dronePort;

  static Future<DjiDrone> init({
    required droneIp,
    required int port,
  }) async {
    var sender = await UDP.bind(Endpoint.any(port: const Port(9000)));
    var videoServer = await UDP.bind(Endpoint.unicast(InternetAddress.tryParse("0.0.0.0"), port: const Port(11111)));

    return DjiDrone._(
      sender: sender,
      reciever: sender.asStream(),
      videoServer: videoServer,
      videoStream: videoServer.asStream(),
      droneIp: droneIp,
      dronePort: port
    );
  }

  void dispose() {
    sender.close();
    videoServer.close();
  }

  void sendData(String data) {
    sender.send(
        data.codeUnits,
        Endpoint.unicast(InternetAddress.tryParse(droneIp),
            port: Port(dronePort)));
  }

  DjiDrone._({
    required this.sender,
    required this.reciever,
    required this.videoServer,
    required this.videoStream,
    required this.droneIp,
    required this.dronePort,
  });
}
