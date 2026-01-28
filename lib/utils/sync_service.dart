import 'dart:io';
import 'dart:convert';
import 'dart:async';

class CipherAuthBroadcaster {
  static const int broadcastPort = 34567;
  static const String serviceType = 'CIPHERAUTH_SYNC';
  static const String broadcastAddress = '255.255.255.255';

  late RawDatagramSocket _socket;
  bool _isRunning = false;
  late Timer _broadcastTimer;

  Future<void> startBroadcasting(String deviceName) async {
    if (_isRunning) return;

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket.broadcastEnabled = true;
      _isRunning = true;

      String localIP = await _getLocalIP();
      print('[BROADCAST] Starting broadcast as "$deviceName" on IP $localIP');

      _broadcastTimer = Timer.periodic(Duration(seconds: 1), (_) {
        final message = {
          'type': serviceType,
          'device_name': deviceName,
          'ip': localIP,
          'timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        };

        final encoded = utf8.encode(jsonEncode(message));
        print('[BROADCAST] Sending: ${jsonEncode(message)}');
        _socket.send(encoded, InternetAddress(broadcastAddress), broadcastPort);
      });
    } catch (e) {
      print('[BROADCAST] Error starting broadcast: $e');
      _isRunning = false;
    }
  }

  void stopBroadcasting() {
    if (!_isRunning) return;
    _broadcastTimer.cancel();
    _socket.close();
    _isRunning = false;
  }

  Future<String> _getLocalIP() async {
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
    return _performDiscovery(excludeDeviceName: excludeDeviceName);
  }

  static Future<List<Map<String, dynamic>>> _performDiscovery({
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
      print('[DISCOVERY] Starting discovery on port $broadcastPort...');

      while (DateTime.now().difference(startTime).inSeconds <
          discoveryTimeoutSeconds) {
        try {
          final datagram = socket.receive();
          if (datagram == null) continue;

          final message = jsonDecode(utf8.decode(datagram.data));
          print('[DISCOVERY] Received: $message from ${datagram.address}');

          if (message['type'] == serviceType) {
            final deviceName = message['device_name'] ?? 'Unknown';

            if (excludeDeviceName != null && deviceName == excludeDeviceName) {
              print('[DISCOVERY] Excluding own device: $deviceName');
              continue;
            }

            final deviceIp = message['ip'] ?? datagram.address.address;
            print('[DISCOVERY] Found device: $deviceName ($deviceIp)');

            devices[deviceName] = {
              'name': deviceName,
              'ip': deviceIp,
              'timestamp': message['timestamp'] ?? 0,
            };
          }
        } catch (e) {
          // Continue 
        }
      }

      socket.close();
      print('[DISCOVERY] Complete. Found ${devices.length} devices');
      return devices.values.toList();
    } catch (e) {
      print('[DISCOVERY] Error: $e');
      return [];
    }
  }
}
