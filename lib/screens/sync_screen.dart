import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => SyncScreenState();
}

class SyncScreenState extends State<SyncScreen> {
  late CipherAuthBroadcaster broadcaster;
  List<Map<String, dynamic>> discoveredDevices = [];
  bool isDiscovering = false;
  bool isBroadcasting = false;
  String deviceName = 'Flutter Device';
  final TextEditingController _deviceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    broadcaster = CipherAuthBroadcaster();
    _loadDeviceName();
  }

  Future<void> _loadDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('device_name') ?? 'Flutter Device';
    setState(() {
      deviceName = savedName;
      _deviceNameController.text = deviceName;
    });
    _startSync();
  }

  Future<void> _saveDeviceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_name', name);
    setState(() => deviceName = name);
    broadcaster.stopBroadcasting();
    _startSync();
  }

  Future<void> _startSync() async {
    setState(() => isBroadcasting = true);
    await broadcaster.startBroadcasting(deviceName);
    _discoverDevices();
  }

  Future<void> _discoverDevices() async {
    setState(() => isDiscovering = true);
    final devices = await compute(_runDiscovery, deviceName);
    setState(() {
      discoveredDevices = devices;
      isDiscovering = false;
    });
  }

  @override
  void dispose() {
    broadcaster.stopBroadcasting();
    _deviceNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Devices')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _deviceNameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        _saveDeviceName(_deviceNameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Device name updated'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBroadcasting ? '📡 Broadcasting...' : 'Ready to sync',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: isDiscovering ? null : _discoverDevices,
                  icon: const Icon(Icons.search),
                  label: const Text('Discover Devices'),
                ),
              ],
            ),
          ),
          Expanded(
            child: discoveredDevices.isEmpty
                ? Center(
                    child: Text(
                      isDiscovering ? 'Searching...' : 'No devices found',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = discoveredDevices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.devices),
                          title: Text(device['name'] ?? 'Unknown'),
                          subtitle: Text(device['ip'] ?? 'No IP'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> _runDiscovery(String? excludeDeviceName) {
  return CipherAuthDiscovery.discoverDevices(
    excludeDeviceName: excludeDeviceName,
  );
}
