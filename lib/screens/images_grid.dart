import 'dart:io';

import 'package:cloud_storage_client/models/my_drive.dart';
import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/material.dart';

class ImagesGrid extends StatelessWidget {
  final List<Image> images;

  const ImagesGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images Grid"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewer(
                    image: images[index],
                    actions: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context, 
                            builder: (context) {
                              return const UploadDialog();
                            }
                          );
                        },
                        icon: const Icon(Icons.upload),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                )
              );
            },
            child: Card(
              child: images[index]
            )
          );
        },
      ),
    );
  }
}

class UploadDialog extends StatefulWidget {
  const UploadDialog({super.key});

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  bool loading = true;
  List<MyDrive> drives = [];

  final storage = Storage();

  @override
  void initState() {
    super.initState();
    storage.getDrives().then((value) => {
      setState(() {
        loading = false;
        drives = value;
      })
    });
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text("Select Drive"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: loading ? [
          const CircularProgressIndicator(),
        ] : drives.map((e) => 
            ListTile(
              leading: e.icon,
              title: Text(e.label),
              onTap: () {
                // TODO: Upload image to drive
              },
            )
          ).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text("Cancel")
        ),
      ],
    );
  }
}