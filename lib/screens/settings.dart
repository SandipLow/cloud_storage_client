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
  List<String> _accessDirectories = [];
  List<String> _ignoreDirectories = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    Directory tempFolder = await Storage.getTemporaryFolder();
    List<Directory> accessDirs = await Storage.getAccessDirectories();
    List<Directory> ignoreDirs = await Storage.getIgnoreDirectories();

    setState(() {
      _temporaryFolder = tempFolder.path;
      _accessDirectories = accessDirs.map((dir) => dir.path).toList();
      _ignoreDirectories = ignoreDirs.map((dir) => dir.path).toList();
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

  Future<void> _showAccessDirectoryDialog() async {
    final TextEditingController _addAccessController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Access Directory"),
          content: TextField(
            controller: _addAccessController,
            decoration: const InputDecoration(hintText: 'Access Directory Path'),
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
                if (_addAccessController.text.isNotEmpty) {
                  await Storage.addAccessDirectory(_addAccessController.text);
                  setState(() {
                    _accessDirectories.add(_addAccessController.text);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showIgnoreDirectoryDialog() async {
    final TextEditingController _addIgnoreController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Ignore Directory"),
          content: TextField(
            controller: _addIgnoreController,
            decoration: const InputDecoration(hintText: 'Ignore Directory Path'),
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
                if (_addIgnoreController.text.isNotEmpty) {
                  await Storage.addIgnoreDirectory(_addIgnoreController.text);
                  setState(() {
                    _ignoreDirectories.add(_addIgnoreController.text);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _manageDirectories(String title, List<String> directories, Function(String) onRemove) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: directories.map((dir) {
                return ListTile(
                  title: Text(dir),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      onRemove(dir);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
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
            subtitle: _temporaryFolder ?? 'Not Set',
            onTap: _showTemporaryFolderDialog,
          ),
          _buildMenuOption(
            title: 'Manage Access Directories',
            subtitle: '${_accessDirectories.length} directories',
            onTap: () => _manageDirectories(
              "Access Directories",
              _accessDirectories,
                  (dir) async {
                await Storage.removeAccessDirectory(dir);
                setState(() {
                  _accessDirectories.remove(dir);
                });
              },
            ),
          ),
          _buildMenuOption(
            title: 'Add Access Directory',
            subtitle: 'Add a new directory',
            onTap: _showAccessDirectoryDialog,
          ),
          _buildMenuOption(
            title: 'Manage Ignore Directories',
            subtitle: '${_ignoreDirectories.length} directories',
            onTap: () => _manageDirectories(
              "Ignore Directories",
              _ignoreDirectories,
                  (dir) async {
                await Storage.removeIgnoreDirectory(dir);
                setState(() {
                  _ignoreDirectories.remove(dir);
                });
              },
            ),
          ),
          _buildMenuOption(
            title: 'Add Ignore Directory',
            subtitle: 'Add a new directory',
            onTap: _showIgnoreDirectoryDialog,
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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
