import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_storage_client/services/storage.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({Key? key}) : super(key: key);

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String? _temporaryFolder;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    Directory tempFolder = await Storage.getTemporaryFolder();

    setState(() {
      _temporaryFolder = tempFolder.path;
    });
  }

  Future<void> _showTemporaryFolderDialog() async {
    final TextEditingController _tempFolderController = TextEditingController();
    _tempFolderController.text = _temporaryFolder ?? '';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Temporary Folder"),
          content: TextField(
            controller: _tempFolderController,
            decoration: const InputDecoration(hintText: 'Temporary Folder Path'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await Storage.setTemporaryFolder(_tempFolderController.text);
                setState(() {
                  _temporaryFolder = _tempFolderController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuOption(
            title: 'Temporary Folder',
            subtitle: "Folder that will be used to store cloud files",
            onTap: _showTemporaryFolderDialog,
          ),
          _buildMenuOption(
            title: 'Access Directories',
            subtitle: 'Manage the directories that can be accessed',
            onTap: () {
              Navigator.of(context).pushNamed('/settings/access_directories');
            },
          ),
          _buildMenuOption(
            title: 'Ignore Directories',
            subtitle: 'Manage the directories that will be ignored',
            onTap: () {
              Navigator.of(context).pushNamed('/settings/ignore_directories');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
