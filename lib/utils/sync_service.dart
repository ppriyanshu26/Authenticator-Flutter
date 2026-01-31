import 'dart:io';
import 'dart:convert';
import 'dart:async';

class CipherAuthBroadcaster {
  static const int broadcastPort = 34567;
  static const String serviceType = 'CIPHERAUTH_SYNC';
  static const String broadcastAddress = '255.255.255.255';

  late RawDatagramSocket socket;
  bool isRunning = false;
  late Timer broadcastTimer;

  Future<void> startBroadcasting(String deviceName) async {
    if (isRunning) return;

    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      isRunning = true;

      String localIP = await getLocalIP();

      broadcastTimer = Timer.periodic(Duration(seconds: 1), (_) {
        final message = {
          'type': serviceType,
          'device_name': deviceName,
          'ip': localIP,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        };

        final encoded = utf8.encode(jsonEncode(message));
        socket.send(encoded, InternetAddress(broadcastAddress), broadcastPort);
      });
    } catch (e) {
      isRunning = false;
    }
  }

  void stopBroadcasting() {
    if (!isRunning) return;
    broadcastTimer.cancel();
    socket.close();
    isRunning = false;
  }

  Future<String> getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        if (!interface.name.contains('docker') &&
            interface.addresses.isNotEmpty) {
          for (final address in interface.addresses) {
            if (address.type == InternetAddressType.IPv4) {
              return address.address;
            }
          }
        }
      }
    } catch (e) {
      return '127.0.0.1';
    }
    return '127.0.0.1';
  }
}

class CipherAuthDiscovery {
  static const int broadcastPort = 34567;
  static const String serviceType = 'CIPHERAUTH_SYNC';
  static const int discoveryTimeoutSeconds = 3;

  static Future<List<Map<String, dynamic>>> discoverDevices({
    String? excludeDeviceName,
  }) async {
    return performDiscovery(excludeDeviceName: excludeDeviceName);
  }

  static Future<List<Map<String, dynamic>>> performDiscovery({
    String? excludeDeviceName,
  }) async {
    final devices = <String, Map<String, dynamic>>{};

    try {
      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        broadcastPort,
      );
      socket.broadcastEnabled = true;

      final startTime = DateTime.now();

      while (DateTime.now().difference(startTime).inSeconds <
          discoveryTimeoutSeconds) {
        try {
          final datagram = socket.receive();
          if (datagram == null) continue;

          final message = jsonDecode(utf8.decode(datagram.data));

          if (message['type'] == serviceType) {
            final deviceName = message['device_name'] ?? 'Unknown';

            if (excludeDeviceName != null && deviceName == excludeDeviceName) {
              continue;
            }

            final deviceIp = message['ip'] ?? datagram.address.address;

            devices[deviceName] = {
              'name': deviceName,
              'ip': deviceIp,
              'timestamp': message['timestamp'] ?? 0,
            };
          }
        } catch (e) {          
          continue;
        }
      }

      socket.close();
      return devices.values.toList();
    } catch (e) {
      return [];
    }
  }
}
