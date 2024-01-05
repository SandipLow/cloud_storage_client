import 'dart:io';

import 'package:cloud_storage_client/services/local_albums.dart';
import 'package:flutter/material.dart';


class ImagesGrid extends StatelessWidget {
  final List<Image>? images;
  final List<File>? imageFiles;
  final Function handleTapImage;

  const ImagesGrid({super.key, this.images, this.imageFiles, required this.handleTapImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images Grid"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: images!=null ? images?.length
                    : imageFiles!=null ? imageFiles?.length
                    : 0,
        itemBuilder: (context, index) {

          if (images!=null) {
            return GestureDetector(
              onTap: () => handleTapImage(images![index], index, context),
              child: Card(
                borderOnForeground: true,
                elevation: 0,
                child: images![index]
              )
            );
          }

          else if (imageFiles!=null) {
            return GestureDetector(
              onTap: () => handleTapImage(Image.file(imageFiles![index]), index, context),
              child: Card(
                borderOnForeground: true,
                elevation: 0,
                child: FutureBuilder(
                  future: LocalAlbumService.getCompressedImage(imageFiles![index].path),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.file(snapshot.data as File);
                    }

                    else {
                      return Container(
                        color: Colors.grey[300],
                      );
                    }
                  },
                )
              )
            );
          }

          return GestureDetector(
            onTap: () {},
            child: Card(
              borderOnForeground: true,
              elevation: 0,
              child: Container(
                color: Colors.grey[300],
              )
            )
          );
        },
      ),
    );
  }
}