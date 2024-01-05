import 'dart:io';

import 'package:cloud_storage_client/models/my_drive.dart';
import 'package:cloud_storage_client/res/colors.dart';
import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:cloud_storage_client/screens/images_grid.dart';
import 'package:cloud_storage_client/services/local_albums.dart';
import 'package:cloud_storage_client/services/storage.dart';
import 'package:flutter/material.dart';

class LocalAlbums extends StatefulWidget {
  const LocalAlbums({super.key});

  @override
  State<LocalAlbums> createState() => _LocalAlbumsState();
}

class _LocalAlbumsState extends State<LocalAlbums> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalAlbumService.getLocalAlbums(), 
      builder: (context, snapshot) {

        if (snapshot.hasData) {
          var localAlbums = snapshot.data as List<LocalAlbum>;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: localAlbums.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ImagesGrid(
                          imageFiles: localAlbums[index]
                                    .files
                                    .map((e) {
                                      return File(e);
                                    })
                                    .toList(),
                          handleTapImage: (image, idx, ctx) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewer(
                                  image: image,
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context, 
                                          builder: (context) {
                                            return UploadDialog( file: File(localAlbums[index].files[idx]) );
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
                        );
                      },
                    ), 
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  color: MyColors.secondary.withOpacity(0.4),
                  child: Stack(
                    children: [
                      Image.file(
                        File(localAlbums[index].thumbnail),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              localAlbums[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}


class UploadDialog extends StatefulWidget {
  final File file;

  const UploadDialog({required this.file, super.key});

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
        ] : drives.map((drive) => 
            ListTile(
              leading: drive.icon,
              title: Text(drive.label),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                drive.providerService.uploadFile(
                  filePath: widget.file.path,
                ).then((result) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Success"))
                  );

                }).catchError((error) {
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Failed"))
                  );

                });

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