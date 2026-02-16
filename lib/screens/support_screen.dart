import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => SupportScreenState();
}

class SupportScreenState extends State<SupportScreen> {
  final EdgeInsets _contentPadding = const EdgeInsets.only(
    left: 56,
    right: 16,
    bottom: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Contact me for support or view our policies',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('Send me an email'),
              children: [
                Padding(
                  padding: _contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email me at:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const SelectableText('cipherauth@ppriyanshu26.online'),
                      const SizedBox(height: 8),
                      const Text(
                        'I would typically respond within 24-48 hours.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.description),
              title: const Text('Privacy Policy'),
              subtitle: const Text('View our privacy policy'),
              children: [
                Padding(
                  padding: _contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      policySection(
                        'Data Storage',
                        'All data is stored locally on your device. We use AES-256-GCM encryption for all sensitive information. No cloud upload.',
                      ),
                      const SizedBox(height: 12),
                      policySection(
                        'What We Store',
                        '• TOTP credentials (platform, username, secret)\n• Master password hash (SHA-256)\n• Biometric settings\n• Theme preferences',
                      ),
                      const SizedBox(height: 12),
                      policySection(
                        'What We Don\'t Collect',
                        '✗ No personal data\n✗ No analytics/tracking\n✗ No usage data\n✗ No biometric samples\n✗ No cloud sync',
                      ),
                      const SizedBox(height: 12),
                      policySection(
                        'Synchronization',
                        'Local network only (same WiFi). Encrypted data transmission. Both devices must have same master password. No internet involved.',
                      ),
                      const SizedBox(height: 12),
                      policySection(
                        'Your Rights',
                        'Export, delete, or reset your data anytime. Full control.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Terms of Service'),
              subtitle: const Text('View our terms and conditions'),
              children: [
                Padding(
                  padding: _contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By using CipherAuth, you agree to our terms of service. This application is provided "as is" without any warranties. You are responsible for maintaining the security of your master password.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'For the complete terms, please visit our website.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              children: [
                Padding(
                  padding: _contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Q: How secure is CipherAuth?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'A: CipherAuth uses military-grade encryption to protect your credentials.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Q: Can I sync my credentials?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'A: Yes, use the Sync to Devices feature in Settings to synchronize across devices.',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Q: What if I forget my master password?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'A: You can reset it using the Reset Password option in Settings.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.handshake),
              title: const Text('Collaborate & Feedback'),
              subtitle: const Text('Help us develop for other platforms'),
              children: [
                Padding(
                  padding: _contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interested in Contributing?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SelectableText(
                        'If you wish to collaborate and develop and test apps on other platforms, you are free to edit and mail your suggestions to us.\nHere is the github repository for the project:',
                      ),
                      const SizedBox(height: 4),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://github.com/ppriyanshu26/CipherAuth-Flutter',
                            ),
                          ),
                          child: const SelectableText(
                            'https://github.com/ppriyanshu26/CipherAuth-Flutter',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Contact me at:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const SelectableText('cipherauth@ppriyanshu26.online'),
                      const SizedBox(height: 12),
                      const Text(
                        'I look forward to hearing from you!',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget policySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
