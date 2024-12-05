import 'dart:io';

import 'package:cloud_storage_client/res/colors.dart';
import 'package:cloud_storage_client/screens/image_viewer.dart';
import 'package:cloud_storage_client/screens/images_grid.dart';
import 'package:cloud_storage_client/services/local_albums.dart';
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
        Navigator.of(context).pushNamed(
          'image_viewer',
          arguments: ImageViewerArgs(
            title: localAlbum.files[idx].split("/").last,
            image: image,
            imagePath: localAlbum.files[idx],
          ),
        );
      },
    );
  }
}


