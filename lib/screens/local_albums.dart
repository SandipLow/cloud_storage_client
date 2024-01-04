import 'dart:io';

import 'package:cloud_storage_client/res/colors.dart';
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
                      builder: (context) => ImagesGrid(
                        images: localAlbums[index].files.map((e) => Image.file(File(e), fit: BoxFit.cover,)).toList(),
                      ),
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