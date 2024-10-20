import 'dart:io';
import 'package:cloud_storage_client/models/my_file.dart';
import 'package:cloud_storage_client/res/strings.dart';
import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:cloud_storage_client/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FileExplorer extends StatefulWidget {
  final String folderName;
  final String? folderId;
  final StorageService providerService;

  const FileExplorer({super.key, this.folderName="File Explorer", required this.providerService, this.folderId});

  @override
  State<FileExplorer> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<MyFile> _files = [];
  bool _isError = false;
  String? _loadingMsg = "Loading files...";

  @override
  void initState() {
    super.initState();

    // Get files in the folder
    widget.providerService.getFolder(folderId: widget.folderId).then((files) {
      setState(() {
        _files = files;
        _loadingMsg = null;
      });
    }).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
      setState(() {
        _isError = true;
        _loadingMsg = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMsg != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_loadingMsg!),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Some Error Occurred"),
        ),
        body: const Center(child: Text("Failed to load files")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) {
              return Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.create_new_folder),
                    title: const Text('New Folder'),
                    onTap: () {
                      // New Folder Code
                      Navigator.pop(context);
                      TextEditingController folderNameController = TextEditingController(text: "New Folder");

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Create New Folder'),
                            content: TextField(
                              controller: folderNameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter folder name',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Create'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _loadingMsg = "Creating new folder";
                                  });

                                  try {
                                    bool success = await widget.providerService.createFolder(
                                      folderName: folderNameController.text,
                                      parentFolderId: widget.folderId,
                                    );

                                    if (!success) throw Exception('Failed to create new folder');

                                    List<MyFile> files = await widget.providerService.getFolder(folderId: widget.folderId);
                                    setState(() {
                                      _files = files;
                                      _loadingMsg = null;
                                    });
                                  }
                                  catch (e) {
                                    if (kDebugMode) print(e.toString());
                                    setState(() {
                                      _loadingMsg = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to create new folder')),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('Upload'),
                    onTap: () async {
                      // Upload File Code
                      Navigator.pop(context);
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result == null) return;

                        File file = File(result.files.single.path!);

                        setState(() {
                          _loadingMsg = "Uploading file: ${file.path.split("/").last}";
                        });

                        await widget.providerService.uploadFile(
                          filePath: file.path,
                          folderId: widget.folderId,
                        );

                        List<MyFile> files = await widget.providerService.getFolder(folderId: widget.folderId);
                        setState(() {
                          _files = files;
                          _loadingMsg = null;
                        });

                      } catch (e) {
                        if (kDebugMode) {
                          print(e.toString());
                        }
                        setState(() {
                          _loadingMsg = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to upload file')),
                        );
                      }

                    },
                  ),
                ],
              );
            },
          );
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
            ),
            ListView.builder(
              itemCount: _files.length,
              itemBuilder: (ctx, idx) {
                return GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Rename'),
                              onTap: () {
                                // Rename file/folder
                                Navigator.of(context).pop();
                                TextEditingController renameController = TextEditingController(text: _files[idx].name);

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Rename File/Folder'),
                                      content: TextField(
                                        controller: renameController,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter new name',
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Rename'),
                                          onPressed: () async {
                                            String newName = renameController.text;

                                            Navigator.of(context).pop();
                                            setState(() {
                                              _loadingMsg = "Renaming ${_files[idx].name}";
                                            });

                                            try {
                                              bool success = await widget.providerService.renameFile(_files[idx].id, newName);

                                              if (!success) throw Exception('Failed to rename ${_files[idx].name}');

                                              List<MyFile> files = await widget.providerService.getFolder(folderId: widget.folderId);
                                              setState(() {
                                                _files = files;
                                              });
                                            }
                                            catch (e) {
                                              if (kDebugMode) print(e.toString());
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to rename ${_files[idx].name}')),
                                              );
                                            }

                                            setState(() {
                                              _loadingMsg = null;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Delete'),
                              onTap: () {
                                // Delete file/folder
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete ?'),
                                    content: Text('Are you sure you want to delete ${_files[idx].name}?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _loadingMsg = "Deleting ${_files[idx].name}";
                                          });
                                          bool success = await widget.providerService.deleteFile(_files[idx].id);
                                          if (success) {
                                            setState(() {
                                              _files.removeAt(idx);
                                              _loadingMsg = null;
                                            });
                                          } else {
                                            setState(() {
                                              _loadingMsg = null;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to delete ${_files[idx].name}')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: _files[idx].icon,
                    title: Text(_files[idx].name),
                    onTap: () {
                      // Folder
                      if (_files[idx].type == Strings.FILE_TYPES_FOLDER) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return FileExplorer(
                              folderName: _files[idx].name,
                              providerService: widget.providerService,
                              folderId: _files[idx].id,
                            );
                          }),
                        );
                      }

                      // Image
                      else if (_files[idx].type == Strings.FILE_TYPES_IMAGE) {
                        showDialog(
                          context: context,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        widget.providerService.downloadFile(_files[idx].id).then((File imgFile) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ImageViewer(
                                title: _files[idx].name,
                                image: Image.file(imgFile),
                                actions: [
                                  IconButton(
                                    onPressed: () async {
                                      await OpenFile.open(imgFile.path);
                                    },
                                    icon: const Icon(Icons.open_in_new),
                                  ),
                                ],
                              );
                            }),
                          );
                        });
                      }

                      // Other
                      else {
                        showDialog(
                          context: context,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        widget.providerService.downloadFile(_files[idx].id).then((File file) async {
                          Navigator.pop(context);
                          await OpenFile.open(file.path);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
