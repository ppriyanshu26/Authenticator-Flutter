import 'package:flutter/material.dart';
import '../utils/crypto.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  String status = '';

  Future<void> _encrypt() async {
    try {
      final result =
      await Crypto.encryptAes(inputController.text);
      outputController.text = result;
      setState(() => status = 'Encrypted ✔');
    } catch (e) {
      setState(() => status = 'Encrypt error');
    }
  }

  Future<void> _decrypt() async {
    try {
      final result =
      await Crypto.decryptAes(inputController.text);
      outputController.text = result;
      setState(() => status = 'Decrypted ✔');
    } catch (e) {
      setState(() => status = 'Decrypt error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AES-GCM Test'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: inputController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child:
                  ElevatedButton(onPressed: _encrypt, child: const Text('Encrypt')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                  ElevatedButton(onPressed: _decrypt, child: const Text('Decrypt')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: outputController,
              maxLines: 6,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(status),
          ],
        ),
      ),
    );
  }
}
