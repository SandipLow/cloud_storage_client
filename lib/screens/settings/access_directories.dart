import 'dart:io';

import 'package:cloud_storage_client/services/storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AccessDirectories extends StatefulWidget {
  const AccessDirectories({super.key});

  @override
  State<AccessDirectories> createState() => _AccessDirectoriesState();
}

class _AccessDirectoriesState extends State<AccessDirectories> {

  List<String> directories = [];

  @override
  void initState() {
    super.initState();
    _loadDirectories();
  }

  Future<void> _loadDirectories() async {
    List<Directory> dirs = await Storage.getAccessDirectories();

    setState(() {
      directories = dirs.map((dir) => dir.path).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Directories'),
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
                        await Storage.removeAccessDirectory(directories[index]);
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
                  await Storage.addAccessDirectory(path);
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