import 'dart:io';

import 'package:cloud_storage_client/services/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class IgnoreDirectories extends StatefulWidget {
  const IgnoreDirectories({super.key});

  @override
  State<IgnoreDirectories> createState() => _IgnoreDirectoriesState();
}

class _IgnoreDirectoriesState extends State<IgnoreDirectories> {

  List<String> directories = [];

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    List<Directory> dirs = await Storage.getIgnoreDirectories();

    setState(() {
      directories = dirs.map((dir) => dir.path).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ignore Directories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: directories.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(directories[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await Storage.removeIgnoreDirectory(directories[index]);
                        _loadDirectories();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                String? path = await FilePicker.platform.getDirectoryPath();

                if (path != null) {
                  await Storage.addIgnoreDirectory(path);
                  _loadDirectories();
                }
              },
              child: const Text('Add Directory'),
            ),
          ),
        ],
      ),
    );
  }
}