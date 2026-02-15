import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About CipherAuth',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CipherAuth is a secure password and authentication manager that helps you store and manage your credentials safely.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Features:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Secure password storage'),
                        Text('• Biometric unlock support'),
                        Text('• Local sync across devices'),
                        Text('• Credential export functionality'),
                        Text('• Master password protection'),
                        Text('• View QR code for credentials'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Version 6.1.1\n© 2026 Priyanshu Priyam\n\nThis app is open source and available on GitHub.\nContributions are welcome!!!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: InkWell(
                    onTap: () async {
                      
                        final uri = Uri.parse('https://www.github.com/ppriyanshu26/');
                        await launchUrl(uri,mode: LaunchMode.externalApplication,);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          FaIcon(FontAwesomeIcons.github, size: 28),
                          SizedBox(height: 4),
                          Text('GitHub', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.parse('https://www.linkedin.com/in/ppriyanshu26/');
                      await launchUrl(uri,mode: LaunchMode.externalApplication,);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          FaIcon(FontAwesomeIcons.linkedin, size: 28),
                          SizedBox(height: 4),
                          Text('LinkedIn', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.parse('https://www.instagram.com/ppriyanshu26_/');
                      await launchUrl(uri,mode: LaunchMode.externalApplication,);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          FaIcon(FontAwesomeIcons.instagram, size: 28),
                          SizedBox(height: 4),
                          Text('Instagram', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
