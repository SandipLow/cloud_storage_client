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

        if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text("Error"));

        var localAlbums = snapshot.data as List<LocalAlbum>;
        final screenWidth = MediaQuery.of(context).size.width;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (screenWidth < 720) ? 2 : (screenWidth < 1080) ? 3 : 4,
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
                      return _ViewAlbum(localAlbum: localAlbums[index]);
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
      },
    );
  }
}


// View Image page to view images in a grid.
class _ViewAlbum extends StatelessWidget {
  const _ViewAlbum({
    required this.localAlbum,
  });

  final LocalAlbum localAlbum;

  @override
  Widget build(BuildContext context) {
    return ImagesGrid(
      title: localAlbum.name,
      imageFiles: localAlbum
                .files
                .map((e) {
                  return File(e);
                })
                .toList(),
      handleTapImage: (image, idx, ctx) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _ViewLocalImage(
              image: image,
              localAlbum: localAlbum,
              idx: idx,
            ),
          )
        );
      },
    );
  }
}


// View Local Image page to view image in full screen.
class _ViewLocalImage extends StatelessWidget {
  const _ViewLocalImage({
    required this.image,
    required this.localAlbum,
    required this.idx,
  });

  final Image image;
  final LocalAlbum localAlbum;
  final int idx;

  @override
  Widget build(BuildContext context) {
    return ImageViewer(
      title: localAlbum.files[idx].split("/").last,
      image: image,
      actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context, 
              builder: (context) {
                return _UploadDialog( file: File(localAlbum.files[idx]) );
              }
            );
          },
          icon: const Icon(Icons.upload),
        ),
        IconButton(
          onPressed: () {
            // handle share
          },
          icon: const Icon(Icons.share),
        ),
        IconButton(
          onPressed: () {
            // handle delete
          },
          icon: const Icon(Icons.delete),
        ),
      ],
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
    Storage.getDrives().then((value) => {
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
                  
                  Navigator.pop(context);

                }).catchError((error) {
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Upload Failed"))
                  );

                  Navigator.pop(context);
                
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