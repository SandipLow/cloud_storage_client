import 'dart:io';
import 'package:cloud_storage_client/models/my_drive.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';

class ImageViewerArgs {
  final String title;
  final Image image;
  final String imagePath;

  ImageViewerArgs({
    required this.title,
    required this.image,
    required this.imagePath,
  });
}

class ImageViewer extends StatelessWidget {
  final String title;
  final Image image;
  final String imagePath;

  const ImageViewer({Key? key, this.title = "Image Viewer", required this.image, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: image,
            ),
          ),

          // Actions bar for the image
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => OpenFile.open(imagePath),
                  icon: const Icon(Icons.open_with),
                ),
                IconButton(
                  onPressed: () => _showInfoDialog(context),
                  icon: const Icon(Icons.info),
                ),
                IconButton(
                  onPressed: () => _deleteFile(context),
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () => _shareFile(),
                  icon: const Icon(Icons.share),
                ),
                IconButton(
                  onPressed: () => _uploadFile(context),
                  icon: const Icon(Icons.upload),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) async {
    final file = File(imagePath);
    final fileSize = await file.length();
    final fileName = file.uri.pathSegments.last;

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("File Info"),
        content: Text("Name: $fileName\nSize: ${fileSize ~/ 1024} KB"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _deleteFile(BuildContext context) async {
    final file = File(imagePath);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File deleted successfully")),
        );
        Navigator.pop(context); // Exit the viewer
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete file")),
        );
      }
    }
  }

  void _shareFile() {
    Share.shareFiles([imagePath], text: "Check out this image!");
  }

  void _uploadFile(BuildContext context) {
    final file = File(imagePath);

    showDialog(
      context: context,
      builder: (context) => _UploadDialog(file: file),
    );
  }
}

// Upload Dialog to select drive and upload opened file.
class _UploadDialog extends StatefulWidget {
  final File file;

  const _UploadDialog({required this.file});

  @override
  State<_UploadDialog> createState() => __UploadDialogState();
}

class __UploadDialogState extends State<_UploadDialog> {
  bool loading = true;
  List<MyDrive> drives = [];

  @override
  void initState() {
    super.initState();
    Storage.getDrives().then((value) {
      setState(() {
        loading = false;
        drives = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Drive"),
      content: loading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: drives.map((drive) {
                return ListTile(
                  leading: drive.icon,
                  title: Text(drive.label),
                  onTap: () {
                    _uploadToDrive(context, drive);
                  },
                );
              }).toList(),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  void _uploadToDrive(BuildContext context, MyDrive drive) {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    drive.providerService.uploadFile(filePath: widget.file.path).then((result) {
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Close upload dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload successful")),
      );
    }).catchError((error) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    });
  }
}
