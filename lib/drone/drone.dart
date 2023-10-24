import 'dart:io';

import 'package:udp/udp.dart';

class DjiDrone {
  final UDP sender;
  final Stream reciever;

  final String droneIp;
  final int dronePort;

  static Future<DjiDrone> init({
    required droneIp,
    required int port,
  }) async {
    var sender = await UDP.bind(Endpoint.any(port: const Port(9000)));

    return DjiDrone._(
      sender: sender,
      reciever: sender.asStream(),
      droneIp: droneIp,
      dronePort: port
    );
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
    required this.droneIp,
    required this.dronePort,
  });
}
