import 'dart:io';

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
              crossAxisCount: 3,
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
                        images: localAlbums[index].files.map((e) => Image.file(File(e), fit: BoxFit.contain,)).toList(),
                      ),
                    ), 
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.file(
                          File(localAlbums[index].thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(localAlbums[index].name),
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