import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/secure_storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _showAISetupDialog() async {
    final controller = TextEditingController();
    final currentKey = await SecureStorageService.getApiKey();
    if (currentKey != null) {
      controller.text = currentKey;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AI Coach Setup'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'Enter your API key here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final key = controller.text.trim();
                if (key.isNotEmpty) {
                  await SecureStorageService.saveApiKey(key);
                } else {
                  await SecureStorageService.deleteApiKey();
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved securely')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Large Text Mode'),
            subtitle: const Text('Increases the font size across the app.'),
            value: settings.largeText,
            onChanged: (val) {
              notifier.updateSettings(settings.copyWith(largeText: val));
            },
          ),
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhances colors for better visibility.'),
            value: settings.highContrast,
            onChanged: (val) {
              notifier.updateSettings(settings.copyWith(highContrast: val));
            },
          ),
          SwitchListTile(
            title: const Text('Voice Feedback (TTS)'),
            subtitle: const Text('Reads out confirmation messages aloud.'),
            value: settings.voiceFeedback,
            onChanged: (val) {
              notifier.updateSettings(settings.copyWith(voiceFeedback: val));
            },
          ),
          SwitchListTile(
            title: const Text('Sedentary Alerts'),
            subtitle: const Text('Reminds you to move after inactivity.'),
            value: settings.sedentaryAlerts,
            onChanged: (val) {
              notifier.updateSettings(settings.copyWith(sedentaryAlerts: val));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('AI Coach Setup'),
            subtitle: const Text('Configure conversational AI parameters.'),
            onTap: _showAISetupDialog,
          ),
        ],
      ),
    );
  }
}
